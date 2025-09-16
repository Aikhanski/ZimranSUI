# Архитектурное руководство для iOS приложений

## Обзор архитектуры

Данная архитектура представляет собой **модульную MVVM архитектуру** с использованием **Dependency Injection** (Swinject), **Combine** для реактивного программирования, **Alamofire** для сетевых запросов и **SwiftUI** для UI.

## Основные принципы

### 1. Модульность
- Каждый экран/функциональность выделен в отдельный модуль
- Модули содержат View, ViewModel и связанные компоненты
- Четкое разделение ответственности между модулями

### 2. Dependency Injection
- Использование Swinject для управления зависимостями
- Все зависимости регистрируются в Assembly классах
- Централизованный DependencyContainer для разрешения зависимостей

### 3. Реактивное программирование
- Использование Combine для обработки асинхронных операций
- ViewModels используют @Published свойства для обновления UI
- Cancellables для управления подписками

## Структура проекта

```
App/
├── DependencyContainer.swift          # Центральный контейнер DI
├── Factory/
│   └── AssemblyFactory.swift         # Фабрика для создания Assembler
├── Router/
│   ├── Router.swift                  # Основной роутер
│   ├── Route.swift                   # Enum маршрутов
│   └── RouterAssembly.swift          # DI для роутера
└── ViewModifiers/
    └── NavigationDestinationModifier.swift

Modules/
├── [ModuleName]/
│   ├── [ModuleName]View.swift        # Основной View
│   ├── View/                         # Дополнительные View компоненты
│   └── ViewModel/
│       └── [ModuleName]ViewModel.swift

Service/
├── [ServiceName]/
│   ├── Public/                       # Публичные интерфейсы
│   │   ├── Protocol/
│   │   └── Model/
│   ├── Private/                      # Приватные реализации
│   └── [ServiceName]Assembly.swift   # DI для сервиса

Foundation/
├── Storages/                         # Система хранения данных
└── Debounce.swift                    # Утилиты

Extension/
└── String + localized.swift          # Расширения

Reusable/
└── ViewModifiers/                    # Переиспользуемые модификаторы
```

## Компоненты архитектуры

### 1. Dependency Injection (Swinject)

#### DependencyContainer
```swift
struct DependencyContainer {
    static let shared = DependencyContainer()
    
    private let assembler = AssemblerFactory().makeAssembler()
    
    func resolve<T>(_ type: T.Type) -> T? {
        assembler.resolver.resolve(T.self)
    }
}
```

#### AssemblyFactory
```swift
final class AssemblerFactory {
    func makeAssembler() -> Assembler {
        Assembler([
            SessionAssembly(),
            BaseURLAssembly(),
            NetworkAssembly(),
            UserAssembly(),
            RepositoriesAssembly(),
            RouterAssembly()
        ])
    }
}
```

#### Пример Assembly
```swift
struct NetworkAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NetworkClient.self) { r in
            let configuration = URLSessionConfiguration.af.default
            configuration.timeoutIntervalForRequest = 30

            let adapter = NetworkAdapter(
                authCredentialsProvider: r.resolve(AuthCredentialsProvider.self)!
            )
            let retrier = NetworkRetrier(
                userSessionDestroyer: r.resolve(UserSessionDestroyer.self)!
            )

            let session = Session(
                configuration: configuration,
                interceptor: Interceptor(adapter: adapter, retrier: retrier)
            )

            return NetworkClientImpl(
                session: session,
                baseURLProvider: r.resolve(BaseURLProvider.self)!
            )
        }.inObjectScope(.weak)
    }
}
```

### 2. Network Layer (Alamofire)

#### NetworkClient Protocol
```swift
protocol NetworkClient: AnyObject {
    func request<Parameters: Encodable, Response: Decodable>(
        _ relativePath: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders?
    ) -> AnyPublisher<Response, Error>
}

// Расширения для удобства
extension NetworkClient {
    func get<Response: Decodable>(
        _ relativePath: String,
        parameters: some Encodable,
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<Response, Error>
    
    func post<Response: Decodable>(
        _ relativePath: String,
        parameters: some Encodable,
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<Response, Error>
}
```

#### NetworkClientImpl
```swift
final class NetworkClientImpl: NetworkClient {
    private let session: Session
    private let baseURLProvider: BaseURLProvider
    private let errorRequestValidator = ErrorURLRequestValidator()

    func request<Parameters: Encodable, Response: Decodable>(
        _ relativePath: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders?
    ) -> AnyPublisher<Response, Error> {
        let request = session.request(
            baseURLProvider.baseURL + relativePath,
            method: method,
            parameters: parameters,
            encoder: ParameterEncoderFactory().makeParameterEncoder(for: method),
            headers: headers
        )

        let validation = errorRequestValidator.validate(request:response:data:)
        return request
            .validate(validation)
            .toFuture()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

### 3. Navigation System

#### Router
```swift
final class Router: ObservableObject {
    @Published var path: [Route] = []

    func showLogin() {
        path.removeAll()
        path.append(.login)
    }

    func showRepositories() {
        path.append(.repositories)
    }

    func showHistory() {
        path.append(.history)
    }

    func pop() {
        path.removeLast()
    }
}
```

#### Route Enum
```swift
enum Route: Hashable {
    case login
    case repositories
    case history
}
```

#### NavigationDestinationModifier
```swift
struct NavigationDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .login:
                    LoginView()
                case .history:
                    HistoryView()
                case .repositories:
                    RepositoriesView()
                }
            }
    }
}
```

### 4. ViewModels

#### Структура ViewModel
```swift
final class [ModuleName]ViewModel: ObservableObject {
    // Published свойства для UI
    @Published var [propertyName]: [Type] = []
    @Published var isLoading = false
    @Published var showError = false
    
    var error: Error?
    
    // Зависимости через DI
    private let [serviceProvider] = DependencyContainer.shared.resolve([ServiceProvider].self)!
    private let router = DependencyContainer.shared.resolve(Router.self)!
    
    // Combine подписки
    private var cancellables: Set<AnyCancellable> = []
    
    // Методы для взаимодействия с UI
    func [actionMethod]() {
        // Реализация
    }
}
```

#### Пример использования в View
```swift
struct [ModuleName]View: View {
    @StateObject var viewModel = [ModuleName]ViewModel()
    
    var body: some View {
        // UI реализация
        .onAppear(perform: viewModel.[initializationMethod])
        .modifier(ErrorAlertModifier(isPresented: $viewModel.showError, error: viewModel.error))
    }
}
```

### 5. Storage System

#### FileStorage (для обычных данных)
```swift
@propertyWrapper
public struct FileStorage<T: Codable & Equatable> {
    public var wrappedValue: T? {
        didSet {
            guard oldValue != wrappedValue else { return }
            updateWrappedValue()
        }
    }
    
    private let directory: DiskDirectory
    private let path: String
    private let disk = Disk()
    
    public init(directory: DiskDirectory = .caches, path: String) {
        self.directory = directory
        self.path = path
        self.wrappedValue = try? disk.retrieve(path, from: directory, as: T.self)
    }
    
    private func updateWrappedValue() {
        if let wrappedValue {
            try? disk.save(wrappedValue, to: directory, as: path)
        } else {
            try? disk.remove(path, from: directory)
        }
    }
}
```

#### ProtectedStorage (для чувствительных данных)
```swift
@propertyWrapper
public struct ProtectedStorage {
    public var wrappedValue: String? {
        didSet {
            guard oldValue != wrappedValue else { return }
            updateWrappedValue()
        }
    }
    
    private let key: String
    private let keychain: Keychain
    
    public init(key: String, accessibility: Accessibility = .always) {
        self.key = key
        self.keychain = Keychain(service: "App Config").accessibility(accessibility)
        self.wrappedValue = try? keychain.get(key)
    }
    
    private func updateWrappedValue() {
        if let wrappedValue {
            try? keychain.set(wrappedValue, key: key)
        } else {
            try? keychain.remove(key)
        }
    }
}
```

## Правила создания приложений с данной архитектурой

### 1. Структура проекта

#### Обязательные папки:
- `App/` - основная конфигурация приложения
- `Modules/` - модули с экранами
- `Service/` - сервисы для работы с данными
- `Foundation/` - базовые компоненты
- `Extension/` - расширения
- `Reusable/` - переиспользуемые компоненты

#### Правила именования:
- Модули: `[FeatureName]` (например, `Login`, `Profile`, `Settings`)
- ViewModels: `[FeatureName]ViewModel`
- Services: `[FeatureName]Provider` (интерфейс), `[FeatureName]Manager` (реализация)
- Assembly: `[FeatureName]Assembly`

### 2. Dependency Injection

#### Правила регистрации:
1. Каждый сервис должен иметь свой Assembly
2. Assembly регистрируется в `AssemblyFactory`
3. Используйте правильные scope:
   - `.container` - для синглтонов (Router, SessionManager)
   - `.weak` - для сервисов с состоянием (NetworkClient)
   - `.transient` - для временных объектов (по умолчанию)

#### Пример создания нового сервиса:
```swift
// 1. Создать протокол
protocol NewServiceProvider {
    func doSomething() -> AnyPublisher<Result, Error>
}

// 2. Создать реализацию
final class NewServiceManager: NewServiceProvider {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func doSomething() -> AnyPublisher<Result, Error> {
        // Реализация
    }
}

// 3. Создать Assembly
struct NewServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewServiceProvider.self) { r in
            NewServiceManager(
                networkClient: r.resolve(NetworkClient.self)!
            )
        }
    }
}

// 4. Добавить в AssemblyFactory
```

### 3. Network Layer

#### Правила создания API:
1. Создайте модели запросов и ответов в `Public/Model/`
2. Используйте `NetworkClient` для всех запросов
3. Все запросы возвращают `AnyPublisher<Response, Error>`
4. Используйте расширения для удобных методов (get, post, delete)

#### Пример API сервиса:
```swift
final class ApiServiceManager: ApiServiceProvider {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchData() -> AnyPublisher<ApiResponse, Error> {
        networkClient.get("/api/data")
    }
    
    func postData(_ data: ApiRequest) -> AnyPublisher<ApiResponse, Error> {
        networkClient.post("/api/data", parameters: data)
    }
}
```

### 4. ViewModels

#### Правила создания ViewModels:
1. Наследуйтесь от `ObservableObject`
2. Используйте `@Published` для свойств, которые влияют на UI
3. Инжектируйте зависимости через `DependencyContainer.shared.resolve`
4. Управляйте `cancellables` для Combine подписок
5. Обрабатывайте ошибки и показывайте их пользователю

#### Шаблон ViewModel:
```swift
final class [FeatureName]ViewModel: ObservableObject {
    @Published var data: [DataType] = []
    @Published var isLoading = false
    @Published var showError = false
    
    var error: Error?
    
    private let [serviceProvider] = DependencyContainer.shared.resolve([ServiceProvider].self)!
    private let router = DependencyContainer.shared.resolve(Router.self)!
    private var cancellables: Set<AnyCancellable> = []
    
    func loadData() {
        isLoading = true
        [serviceProvider].[method]()
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error
                    self?.showError = true
                case .finished:
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] result in
                self?.data = result
            }
            .store(in: &cancellables)
    }
}
```

### 5. Navigation

#### Правила навигации:
1. Добавляйте новые маршруты в `Route` enum
2. Обновляйте `NavigationDestinationModifier` для новых экранов
3. Используйте методы Router для навигации
4. Не создавайте прямые ссылки между View

#### Пример добавления нового экрана:
```swift
// 1. Добавить в Route
enum Route: Hashable {
    case login
    case repositories
    case history
    case newScreen  // Новый маршрут
}

// 2. Добавить метод в Router
func showNewScreen() {
    path.append(.newScreen)
}

// 3. Обновить NavigationDestinationModifier
case .newScreen:
    NewScreenView()
```

### 6. Storage

#### Правила использования Storage:
1. Используйте `FileStorage` для обычных данных
2. Используйте `ProtectedStorage` для чувствительных данных (токены, пароли)
3. Создавайте отдельные ключи для каждого типа данных
4. Используйте Property Wrappers для автоматического сохранения

#### Пример использования:
```swift
final class UserSessionManager: AuthCredentialsProvider {
    @ProtectedStorage(key: "auth_token")
    private var authToken: String?
    
    @FileStorage(path: "user_profile")
    private var userProfile: User?
    
    var token: String? { authToken }
    
    func setToken(_ token: String) {
        authToken = token
    }
}
```

### 7. Локализация

#### Правила локализации:
1. Используйте расширение `String.localized()`
2. Создайте `.strings` файлы для каждого языка
3. Используйте ключи в camelCase
4. Группируйте ключи по функциональности

#### Пример:
```swift
extension String {
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}

// Использование
Text("sign_in".localized())
```

### 8. Error Handling

#### Правила обработки ошибок:
1. Используйте `ErrorAlertModifier` для показа ошибок
2. Создайте кастомные типы ошибок при необходимости
3. Логируйте ошибки для отладки
4. Предоставляйте понятные сообщения пользователю

#### Пример:
```swift
.modifier(ErrorAlertModifier(isPresented: $viewModel.showError, error: viewModel.error))
```

## Зависимости

### Обязательные зависимости:
- **Swinject** - Dependency Injection
- **Alamofire** - Network requests
- **Combine** - Reactive programming (встроен в iOS 13+)
- **KeychainAccess** - Secure storage
- **SwiftUI** - UI framework (iOS 13+)

### Рекомендуемые зависимости:
- **SwiftLint** - Code style
- **Quick/Nimble** - Unit testing
- **SnapshotTesting** - UI testing

## Заключение

Данная архитектура обеспечивает:
- **Модульность** - легко добавлять новые функции
- **Тестируемость** - все зависимости инжектируются
- **Масштабируемость** - четкое разделение ответственности
- **Поддерживаемость** - понятная структура и паттерны
- **Производительность** - эффективное управление памятью

Следуя этим правилам, вы сможете создавать приложения с аналогичной архитектурой, которые будут легко поддерживать и расширять.
