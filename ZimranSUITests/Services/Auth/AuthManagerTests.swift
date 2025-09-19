//
//  AuthManagerTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 17.09.2025.
//

import Testing
import Combine
import Foundation
import AuthenticationServices
@testable import ZimranSUI

// TODO: Исправить ошибки Swinject и Swift макросов
/*
struct AuthManagerTests {
    
    // MARK: - Тесты
    
    @Test("Инициализация AuthManager - не аутентифицирован")
    func testInitialStateNotAuthenticated() {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        let mockGitHubUserProvider = MockGitHubUserProvider()
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        #expect(!authManager.isAuthenticated)
        #expect(authManager.currentUser == nil)
    }
    
    @Test("Инициализация AuthManager - аутентифицирован")
    func testInitialStateAuthenticated() async throws {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        mockCredentialsProvider.setToken("test_token")
        let mockGitHubUserProvider = MockGitHubUserProvider()
        mockGitHubUserProvider.getAuthenticatedUserResult = .success(AuthenticatedUser(id: 1, login: "test", avatarURL: "url", htmlURL: "html", name: "Auth User", email: nil, bio: nil, company: nil, blog: nil, location: nil, type: "User", siteAdmin: false, followers: 0, following: 0, publicRepos: 0, publicGists: 0, createdAt: "2023-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z"))
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        // Даем время для загрузки информации о пользователе
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        #expect(authManager.isAuthenticated)
        #expect(authManager.currentUser?.login == "authuser")
    }
    
    @Test("Выход из системы")
    func testSignOut() {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        mockCredentialsProvider.setToken("test_token")
        let mockGitHubUserProvider = MockGitHubUserProvider()
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        authManager.signOut()
        
        #expect(!authManager.isAuthenticated)
        #expect(authManager.currentUser == nil)
        #expect(mockCredentialsProvider.token == nil)
        #expect(mockUserSessionDestroyer.destroySessionCalled)
    }
    
    @Test("Аутентификация с токеном")
    func testAuthenticateWithToken() async throws {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        let mockGitHubUserProvider = MockGitHubUserProvider()
        mockGitHubUserProvider.getAuthenticatedUserResult = .success(AuthenticatedUser(id: 1, login: "test", avatarURL: "url", htmlURL: "html", name: "Auth User", email: nil, bio: nil, company: nil, blog: nil, location: nil, type: "User", siteAdmin: false, followers: 0, following: 0, publicRepos: 0, publicGists: 0, createdAt: "2023-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z"))
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        let result = try await authManager.authenticateWithToken("test_token").async()
        
        #expect(authManager.isAuthenticated)
        #expect(authManager.currentUser?.login == "test")
        #expect(result.login == "test")
        #expect(mockCredentialsProvider.token == "test_token")
    }
    
    @Test("Аутентификация с токеном - ошибка")
    func testAuthenticateWithTokenError() async throws {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        let mockGitHubUserProvider = MockGitHubUserProvider()
        mockGitHubUserProvider.getAuthenticatedUserResult = .failure(URLError(.badServerResponse))
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        await #expect(throws: URLError.self) {
            _ = try await authManager.authenticateWithToken("invalid_token").async()
        }
    }
    
    @Test("Проверка состояния аутентификации")
    func testAuthenticationState() {
        let mockCredentialsProvider = MockAuthCredentialsProvider()
        let mockGitHubUserProvider = MockGitHubUserProvider()
        let mockUserSessionDestroyer = MockUserSessionDestroyer()
        let authManager = AuthManager(authCredentialsProvider: mockCredentialsProvider, githubUserProvider: mockGitHubUserProvider, userSessionDestroyer: mockUserSessionDestroyer)
        
        #expect(!authManager.isAuthenticated)
        #expect(authManager.currentUser == nil)
        
        // Симулируем аутентификацию
        authManager.isAuthenticated = true
        authManager.currentUser = AuthenticatedUser(id: 1, login: "testuser", avatarURL: "url", htmlURL: "html", name: "Test User", email: nil, bio: nil, company: nil, blog: nil, location: nil, type: "User", siteAdmin: false, followers: 0, following: 0, publicRepos: 0, publicGists: 0, createdAt: "2023-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z")
        
        #expect(authManager.isAuthenticated)
        #expect(authManager.currentUser?.login == "testuser")
    }
}

// MARK: - Моки
extension AuthManagerTests {
    
    private final class MockAuthCredentialsProvider: AuthCredentialsProvider {
        var token: String?
        
        func setToken(_ token: String?) {
            self.token = token
        }
        
        func clearToken() {
            self.token = nil
        }
    }
    
    private final class MockGitHubUserProvider: GitHubUserProvider {
        var searchUsersResult: Result<SearchUsersResponse, Error> = .success(SearchUsersResponse(totalCount: 0, items: [], incompleteResults: false))
        var getUserResult: Result<UserModel, Error> = .success(UserModel(id: 1, login: "test", avatarUrl: "test", htmlUrl: "test", type: "User", siteAdmin: false))
        var getAuthenticatedUserResult: Result<AuthenticatedUser, Error> = .success(AuthenticatedUser(id: 1, login: "test", avatarURL: "test", htmlURL: "test", name: "Test", email: nil, bio: nil, company: nil, blog: nil, location: nil, type: "User", siteAdmin: false, followers: 0, following: 0, publicRepos: 0, publicGists: 0, createdAt: "2023-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z"))
        
        func searchUsers(query: String, sort: UserSortOption, order: ZimranSUI.SortOrder) -> AnyPublisher<SearchUsersResponse, Error> {
            return searchUsersResult.publisher.eraseToAnyPublisher()
        }
        
        func getUser(username: String) -> AnyPublisher<UserModel, Error> {
            return getUserResult.publisher.eraseToAnyPublisher()
        }
        
        func getAuthenticatedUser() -> AnyPublisher<AuthenticatedUser, Error> {
            return getAuthenticatedUserResult.publisher.eraseToAnyPublisher()
        }
    }
    
    private final class MockUserSessionDestroyer: UserSessionDestroyer {
        var destroySessionCalled = false
        func destroySession() {
            destroySessionCalled = true
        }
    }
}
*/
