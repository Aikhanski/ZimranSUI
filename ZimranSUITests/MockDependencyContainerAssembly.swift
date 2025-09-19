//
//  MockDependencyContainerAssembly.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Foundation
import Swinject
import Combine
import Alamofire
@testable import ZimranSUI

struct MockDependencyContainerAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(AuthCredentialsProvider.self) { _ in
            MockAuthCredentialsProvider()
        }.inObjectScope(.container)
        
        container.register(UserSessionDestroyer.self) { _ in
            MockUserSessionDestroyer()
        }.inObjectScope(.container)
        
        container.register(AuthProvider.self) { _ in
            MockAuthProvider()
        }.inObjectScope(.container)
        
        container.register(GitHubUserProvider.self) { _ in
            MockGitHubUserProvider()
        }.inObjectScope(.container)
        
        container.register(GitHubRepositoryProvider.self) { _ in
            MockGitHubRepositoryProvider()
        }.inObjectScope(.container)
        
        container.register(NetworkClient.self) { _ in
            MockNetworkClient()
        }.inObjectScope(.container)
        
        container.register(BaseURLProvider.self) { _ in
            MockBaseURLProvider()
        }.inObjectScope(.container)
        
        container.register(HistoryStorageProvider.self) { _ in
            MockHistoryStorageProvider()
        }.inObjectScope(.container)
        
        container.register((any RouterProtocol).self) { _ in
            MockRouter()
        }.inObjectScope(.container)
        
        container.register(RepositorySearchServiceProtocol.self) { _ in
            MockRepositorySearchService()
        }.inObjectScope(.container)
    }
}
    class MockAuthCredentialsProvider: AuthCredentialsProvider {
    var token: String?
    
    func setToken(_ token: String?) {
        self.token = token
    }
    
    func clearToken() {
        self.token = nil
    }
}

    class MockUserSessionDestroyer: UserSessionDestroyer {
    var destroySessionCalled = false
    
    func destroySession() {
        destroySessionCalled = true
    }
}

    class MockAuthProvider: AuthProvider, ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: AuthenticatedUser?
    
    func authenticateWithToken(_ token: String) -> AnyPublisher<AuthenticatedUser, Error> {
        let user = AuthenticatedUser(
            id: 1,
            login: "testuser",
            avatarURL: "https://example.com/avatar.png",
            htmlURL: "https://github.com/testuser",
            name: "Test User",
            email: "test@example.com",
            bio: "Test bio",
            company: "Test Company",
            blog: "https://testuser.blog",
            location: "Test City",
            type: "User",
            siteAdmin: false,
            followers: 100,
            following: 50,
            publicRepos: 25,
            publicGists: 5,
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-12-01T00:00:00Z"
        )
        
        isAuthenticated = true
        currentUser = user
        
        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func authenticateWithOAuth() -> AnyPublisher<AuthenticatedUser, Error> {
        isAuthenticated = true
        return authenticateWithToken("mock_token")
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
}

class MockGitHubUserProvider: GitHubUserProvider {
    
    var searchUsersResult: Result<SearchUsersResponse, Error> = .success(
        SearchUsersResponse(
            totalCount: 0,
            items: [],
            incompleteResults: false
        )
    )
    var getUserResult: Result<UserModel, Error> = .success(
        UserModel(
            id: 1,
            login: "test",
            avatarUrl: "test",
            htmlUrl: "test",
            type: "User",
            siteAdmin: false
        )
    )
    var getAuthenticatedUserResult: Result<AuthenticatedUser, Error> = .success(
        AuthenticatedUser(
            id: 1,
            login: "test",
            avatarURL: "test",
            htmlURL: "test",
            name: "Test",
            email: nil,
            bio: nil,
            company: nil,
            blog: nil,
            location: nil,
            type: "User",
            siteAdmin: false,
            followers: 0,
            following: 0,
            publicRepos: 0,
            publicGists: 0,
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z"
        )
    )
    
    func searchUsers(
        query: String,
        sort: UserSortOption,
        order: ZimranSUI.SortOrder
    ) -> AnyPublisher<SearchUsersResponse, Error> {
        return searchUsersResult.publisher.eraseToAnyPublisher()
    }
    
    func getUser(username: String) -> AnyPublisher<UserModel, Error> {
        return getUserResult.publisher.eraseToAnyPublisher()
    }
    
    func getAuthenticatedUser() -> AnyPublisher<AuthenticatedUser, Error> {
        return getAuthenticatedUserResult.publisher.eraseToAnyPublisher()
    }
}

class MockGitHubRepositoryProvider: GitHubRepositoryProvider {
    var searchRepositoriesResult: Result<SearchRepositoriesResponse, Error> = .success(
        SearchRepositoriesResponse(totalCount: 0, items: [], incompleteResults: false)
    )
    var getUserRepositoriesResult: Result<[RepositoryModel], Error> = .success([])

    var searchRepositoriesCalled = false
    var lastSearchParameters: RepositorySearchParameters?
    var getUserRepositoriesCalled = false
    var lastUsername: String?
    
    func searchRepositories(
        parameters: RepositorySearchParameters
    ) -> AnyPublisher<SearchRepositoriesResponse, Error> {
        searchRepositoriesCalled = true
        lastSearchParameters = parameters
        return searchRepositoriesResult.publisher.eraseToAnyPublisher()
    }
    
    func getUserRepositories(username: String) -> AnyPublisher<[RepositoryModel], Error> {
        getUserRepositoriesCalled = true
        lastUsername = username
        return getUserRepositoriesResult.publisher.eraseToAnyPublisher()
    }
}

public class MockNetworkClient: NetworkClient {
    
    var searchUsersResult: Result<SearchUsersResponse, Error> = .success(
        SearchUsersResponse(
            totalCount: 0,
            items: [],
            incompleteResults: false
        )
    )
    
    var lastPath: String?
    var requestCount = 0
    var getUserResult: Result<UserModel, Error> = .success(
        UserModel(
            id: 1,
            login: "test",
            avatarUrl: "test",
            htmlUrl: "test",
            type: "User",
            siteAdmin: false
        )
    )
    var getAuthenticatedUserResult: Result<AuthenticatedUser, Error> = .success(
        AuthenticatedUser(
            id: 1,
            login: "test",
            avatarURL: "test",
            htmlURL: "test",
            name: "Test",
            email: nil,
            bio: nil,
            company: nil,
            blog: nil,
            location: nil,
            type: "User",
            siteAdmin: false,
            followers: 0,
            following: 0,
            publicRepos: 0,
            publicGists: 0,
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z"
        )
    )
    
    public func request<Parameters: Encodable, Response: Decodable>(
        _ relativePath: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders?
    ) -> AnyPublisher<Response, Error> {
        lastPath = relativePath
        requestCount += 1
        
        if relativePath.contains("search/users") {
            return searchUsersResult
                .map { result in
                    guard let response = result as? Response else {
                        fatalError("Type mismatch: expected \(Response.self), got \(type(of: result))")
                    }
                    return response
                }
                .publisher
                .eraseToAnyPublisher()
        } else if relativePath.contains("users/") && !relativePath.contains("search") {
            return getUserResult
                .map { result in
                    guard let response = result as? Response else {
                        fatalError("Type mismatch: expected \(Response.self), got \(type(of: result))")
                    }
                    return response
                }
                .publisher
                .eraseToAnyPublisher()
        } else if relativePath == "user" {
            return getAuthenticatedUserResult
                .map { result in
                    guard let response = result as? Response else {
                        fatalError("Type mismatch: expected \(Response.self), got \(type(of: result))")
                    }
                    return response
                }
                .publisher
                .eraseToAnyPublisher()
        }
        
        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
}

class MockBaseURLProvider: BaseURLProvider {
    var baseURL: String = "https://api.github.com"
}

class MockHistoryStorageProvider: HistoryStorageProvider {
    
    var repositoryHistory: [HistoryItem] = []
    var userHistory: [HistoryItem] = []
    
    // Test tracking properties
    var addRepositoryToHistoryCalled = false
    var lastAddedRepository: RepositoryModel?
    var addUserToHistoryCalled = false
    var lastAddedUser: UserModel?
    
    func getRepositoryHistory() -> [HistoryItem] {
        return repositoryHistory.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func getUserHistory() -> [HistoryItem] {
        return userHistory.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func addRepositoryToHistory(_ repository: RepositoryModel) {
        addRepositoryToHistoryCalled = true
        lastAddedRepository = repository
        let historyItem = HistoryItem(repository: repository)
        repositoryHistory.append(historyItem)
    }
    
    func addUserToHistory(_ user: UserModel) {
        addUserToHistoryCalled = true
        lastAddedUser = user
        let historyItem = HistoryItem(user: user)
        userHistory.append(historyItem)
    }
    
    func deleteRepositoryHistoryItem(_ id: String) {
        repositoryHistory.removeAll { $0.id == id }
    }
    
    func deleteUserHistoryItem(_ id: String) {
        userHistory.removeAll { $0.id == id }
    }
    
    func clearRepositoryHistory() {
        repositoryHistory.removeAll()
    }
    
    func clearUserHistory() {
        userHistory.removeAll()
    }
}

class MockRouter: RouterProtocol, ObservableObject {
    @Published var path: [Route] = []
    
    func showAuthentication() {
        path.removeAll()
        path.append(.authentication)
    }
    
    func showRepositorySearch() {
        path.removeAll()
        path.append(.repositorySearch)
    }
    
    func showUserSearch() {
        path.append(.userSearch)
    }
    
    func showHistory() {
        path.append(.history)
    }
    
    func showSettings() {
        path.append(.profile)
    }
    
    func showUserRepositories() {
        path.append(.userRepositories)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
}

class MockRepositorySearchService: RepositorySearchServiceProtocol {
    var searchRepositoriesResult: Result<SearchRepositoriesResponse, Error> = .success(
        SearchRepositoriesResponse(
            totalCount: 0,
            items: [],
            incompleteResults: false
        )
    )
    
    func searchRepositories(
        query: String,
        sortOption: RepositorySortOption,
        sortOrder: ZimranSUI.SortOrder,
        page: Int
    ) -> AnyPublisher<SearchRepositoriesResponse, Error> {
        return searchRepositoriesResult.publisher.eraseToAnyPublisher()
    }
}
