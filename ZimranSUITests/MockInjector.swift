//
//  MockInjector.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Foundation
import Swinject
import SwiftUI
import Combine
@testable import ZimranSUI

/// Протокол для удобной инъекции моков в тестах
protocol MockInjector {
    /// Получить мок для указанного типа
    func injectedMock<T>(for type: T.Type) -> T
}

/// Extension для MockInjector с реализацией
extension MockInjector {
    
    /// Получить мок для указанного типа
    func injectedMock<T>(for type: T.Type) -> T {
        let container = TestDI.makeContainer()
        guard let resolved = container.resolve(type) else {
            fatalError("❌ Не удалось резолвить \(type)")
        }
        return resolved
    }
}


/// Утилиты для работы с моками в тестах
struct MockTestUtils {
    
    /// Получить мок для конкретного типа
    static func getMock<T>(_ type: T.Type) -> T {
        let container = TestDI.makeContainer()
        guard let resolved = container.resolve(type) else {
            fatalError("❌ Не удалось резолвить \(type)")
        }
        return resolved
    }
}


/// Extension для удобной работы с моками в тестах
extension MockInjector {
    
    /// Получить мок AuthProvider
    var mockAuthProvider: AuthProvider {
        return injectedMock(for: AuthProvider.self)
    }
    
    /// Получить мок GitHubUserProvider
    var mockGitHubUserProvider: GitHubUserProvider {
        return injectedMock(for: GitHubUserProvider.self)
    }
    
    /// Получить мок GitHubRepositoryProvider
    var mockGitHubRepositoryProvider: GitHubRepositoryProvider {
        return injectedMock(for: GitHubRepositoryProvider.self)
    }
    
    /// Получить мок NetworkClient
    var mockNetworkClient: NetworkClient {
        return injectedMock(for: NetworkClient.self)
    }
    
    /// Получить мок HistoryStorageProvider
    var mockHistoryStorageProvider: HistoryStorageProvider {
        return injectedMock(for: HistoryStorageProvider.self)
    }
    
    /// Получить мок Router
    var mockRouter: any RouterProtocol {
        return injectedMock(for: (any RouterProtocol).self)
    }
    
    /// Получить мок RepositorySearchService
    var mockRepositorySearchService: RepositorySearchServiceProtocol {
        return injectedMock(for: RepositorySearchServiceProtocol.self)
    }
}

/// Базовый класс для тестов с поддержкой моков
open class MockTestBase: MockInjector {
    
    /// Настройка моков перед каждым тестом
    open func setUpMocks() {
        // Переопределите в наследниках для настройки конкретных моков
    }
    
    /// Очистка моков после каждого теста
    open func tearDownMocks() {
        // Переопределите в наследниках для очистки моков
    }
}
