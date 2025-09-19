//
//  GitHubUserProviderTests.swift
//  ZimranSUI
//
//  Created by Aikhan on 19.09.2025.
//

//
//

import Testing
import Combine
import Foundation
import Alamofire
@testable import ZimranSUI
@Suite(.serialized)
struct GitHubUserProviderTests: MockInjector {
    
    @Test("Поиск пользователей с успешным результатом")
    func testSearchUsersSuccess() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let testUsers = [
            UserModel(
                id: 1,
                login: "testuser1",
                avatarUrl: "https://example.com/avatar1.png",
                htmlUrl: "https://github.com/testuser1",
                type: "User",
                siteAdmin: false
            ),
            UserModel(
                id: 2,
                login: "testuser2",
                avatarUrl: "https://example.com/avatar2.png",
                htmlUrl: "https://github.com/testuser2",
                type: "User",
                siteAdmin: false
            )
        ]
        let searchResponse = SearchUsersResponse(totalCount: 2, items: testUsers, incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(searchResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)

        let response = try await provider.searchUsers(
            query: "test",
            sort: ZimranSUI.UserSortOption.bestMatch,
            order: ZimranSUI.SortOrder.desc
        ).async()

        #expect(response.totalCount == 2)
        #expect(response.items.count == 2)
        #expect(response.items[0].login == "testuser1")
        #expect(response.items[1].login == "testuser2")
        #expect(response.incompleteResults == false)
        #expect(mockNetworkClient.lastPath?.contains("search/users") == true)
    }
    
    @Test("Поиск пользователей с параметрами сортировки")
    func testSearchUsersWithSorting() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let testUsers = [UserModel(id: 1, login: "testuser", avatarUrl: "url", htmlUrl: "html", type: "User", siteAdmin: false)]
        let searchResponse = SearchUsersResponse(totalCount: 1, items: testUsers, incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(searchResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        _ = try await provider.searchUsers(query: "swift", sort: ZimranSUI.UserSortOption.followers, order: ZimranSUI.SortOrder.asc).async()
        
        #expect(mockNetworkClient.lastPath?.contains("search/users") == true)
    }
    
    @Test("Поиск пользователей с ошибкой сети")
    func testSearchUsersNetworkError() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.searchUsersResult = .failure(URLError(.notConnectedToInternet))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        do {
            _ = try await provider.searchUsers(query: "test", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
            #expect(Bool(false), "Ожидалась ошибка сети")
        } catch {
            #expect(error is URLError)
        }
    }
    
    @Test("Поиск пользователей с ошибкой сервера")
    func testSearchUsersServerError() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.searchUsersResult = .failure(URLError(.badServerResponse))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.searchUsers(query: "test", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
        }
    }
    
    @Test("Поиск пользователей с пустым результатом")
    func testSearchUsersEmptyResult() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let emptyResponse = SearchUsersResponse(totalCount: 0, items: [], incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(emptyResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        let response = try await provider.searchUsers(query: "nonexistent", sort: .bestMatch, order: .desc).async()
        
        #expect(response.totalCount == 0)
        #expect(response.items.isEmpty)
        #expect(response.incompleteResults == false)
    }
    
    
    @Test("Получение пользователя по имени")
    func testGetUserSuccess() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let testUser = UserModel(id: 123, login: "testuser", avatarUrl: "https://example.com/avatar.png", htmlUrl: "https://github.com/testuser", type: "User", siteAdmin: false)
        mockNetworkClient.getUserResult = .success(testUser)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        let user = try await provider.getUser(username: "testuser").async()
        
        #expect(user.id == 123)
        #expect(user.login == "testuser")
        #expect(user.type == "User")
        #expect(user.siteAdmin == false)
        #expect(mockNetworkClient.lastPath?.contains("users/testuser") == true)
    }
    
    @Test("Получение пользователя с ошибкой")
    func testGetUserError() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.getUserResult = .failure(URLError(.resourceUnavailable))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.getUser(username: "nonexistent").async()
        }
    }
    
    @Test("Получение пользователя с неверным именем")
    func testGetUserWithInvalidUsername() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.getUserResult = .failure(URLError(.badURL))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.getUser(username: "").async()
        }
    }
    
    @Test("Получение аутентифицированного пользователя с ошибкой авторизации")
    func testGetAuthenticatedUserAuthError() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.getAuthenticatedUserResult = .failure(URLError(.userAuthenticationRequired))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.getAuthenticatedUser().async()
        }
    }
    
    
    @Test("Обработка ошибки 404")
    func testHandle404Error() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.getUserResult = .failure(URLError(.resourceUnavailable))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.getUser(username: "nonexistent").async()
        }
    }
    
    @Test("Обработка ошибки 403 (Rate Limit)")
    func testHandle403Error() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.searchUsersResult = .failure(URLError(.userAuthenticationRequired))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.searchUsers(query: "test", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
        }
    }
    
    @Test("Обработка ошибки 500")
    func testHandle500Error() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        mockNetworkClient.searchUsersResult = .failure(URLError(.badServerResponse))
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        await #expect(throws: URLError.self) {
            _ = try await provider.searchUsers(query: "test", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
        }
    }
    
    
    @Test("Валидация пустого запроса поиска")
    func testValidateEmptySearchQuery() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let emptyResponse = SearchUsersResponse(totalCount: 0, items: [], incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(emptyResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        let response = try await provider.searchUsers(query: "", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
        
        #expect(response.totalCount == 0)
        #expect(response.items.isEmpty)
    }
    
    @Test("Валидация специальных символов в запросе")
    func testValidateSpecialCharactersInQuery() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let testUsers = [UserModel(id: 1, login: "testuser", avatarUrl: "url", htmlUrl: "html", type: "User", siteAdmin: false)]
        let searchResponse = SearchUsersResponse(totalCount: 1, items: testUsers, incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(searchResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        _ = try await provider.searchUsers(query: "test@#$%", sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
        
        #expect(mockNetworkClient.lastPath?.contains("search/users") == true)
    }
    
    
    @Test("Множественные запросы поиска")
    func testMultipleSearchRequests() async throws {
        let mockNetworkClient = injectedMock(for: NetworkClient.self) as! MockNetworkClient
        let testUsers = [UserModel(id: 1, login: "testuser", avatarUrl: "url", htmlUrl: "html", type: "User", siteAdmin: false)]
        let searchResponse = SearchUsersResponse(totalCount: 1, items: testUsers, incompleteResults: false)
        mockNetworkClient.searchUsersResult = .success(searchResponse)
        
        let provider = GitHubUserManager(networkClient: mockNetworkClient)
        
        let queries = ["swift", "ios", "xcode", "github"]
        var responses: [SearchUsersResponse] = []
        
        for query in queries {
            let response = try await provider.searchUsers(query: query, sort: ZimranSUI.UserSortOption.bestMatch, order: ZimranSUI.SortOrder.desc).async()
            responses.append(response)
        }
        
        #expect(responses.count == 4)
        #expect(mockNetworkClient.requestCount == 4)
        for response in responses {
            #expect(response.totalCount == 1)
            #expect(response.items.count == 1)
        }
    }
}
