//
//  SearchViewModelTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 17.09.2025.
//

import Testing
import Combine
import Foundation
@testable import ZimranSUI

struct SearchViewModelTests: MockInjector {

    var mockGitHubUserProvider: GitHubUserProvider!
    var mockHistoryStorageProvider: HistoryStorageProvider!
    var mockRouter: (any RouterProtocol)?
    
    init() {
        mockGitHubUserProvider = injectedMock(for: GitHubUserProvider.self)
        mockHistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        mockRouter = injectedMock(for: (any RouterProtocol).self)
    }
    
    private func createViewModel() -> SearchViewModel {
        return SearchViewModel(
            githubUserProvider: mockGitHubUserProvider,
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter!
        )
    }
    
    @Test("Инициализация SearchViewModel")
    func testInitialization() {
        let viewModel = createViewModel()

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.users.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.showError)
        #expect(viewModel.sortOption == .bestMatch)
        #expect(viewModel.sortOrder == .desc)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.hasMoreData)
        #expect(viewModel.totalCount == 0)
    }
    
    @Test("Изменение опции сортировки")
    func testChangeSortOption() {
        let viewModel = createViewModel()
        viewModel.changeSortOption(.followers)

        #expect(viewModel.sortOption == .followers)
    }
    
    @Test("Поиск с пустым текстом")
    func testSearchWithEmptyText() {
        let viewModel = createViewModel()
        viewModel.searchText = "   "
        viewModel.users = [UserModel(id: 1, login: "user1", avatarUrl: "url", htmlUrl: "html", type: "User", siteAdmin: false)]

        viewModel.search()

        #expect(viewModel.searchText == "   ")
        #expect(viewModel.users.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.showError)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.totalCount == 0)
    }
    
    @Test("Установка текста поиска")
    func testSetSearchText() {
        let viewModel = createViewModel()

        viewModel.searchText = "test query"

        #expect(viewModel.searchText == "test query")
    }
    
    @Test("Установка пользователей")
    func testSetUsers() {
        let viewModel = createViewModel()
        let testUsers = [
            UserModel(id: 1, login: "user1", avatarUrl: "url1", htmlUrl: "html1", type: "User", siteAdmin: false),
            UserModel(id: 2, login: "user2", avatarUrl: "url2", htmlUrl: "html2", type: "User", siteAdmin: false)
        ]

        viewModel.users = testUsers

        #expect(viewModel.users.count == 2)
        #expect(viewModel.users[0].login == "user1")
        #expect(viewModel.users[1].login == "user2")
    }
    
    @Test("Установка состояния загрузки")
    func testSetLoadingState() {
        let viewModel = createViewModel()

        viewModel.isLoading = true

        #expect(viewModel.isLoading == true)

        viewModel.isLoading = false

        #expect(viewModel.isLoading == false)
    }
    
    @Test("Установка состояния ошибки")
    func testSetErrorState() {
        let viewModel = createViewModel()
        let testError = URLError(.badServerResponse)

        viewModel.showError = true
        viewModel.error = testError

        #expect(viewModel.showError == true)
        #expect(viewModel.error is URLError)

        viewModel.showError = false
        viewModel.error = nil
        
        #expect(viewModel.showError == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("Установка пагинации")
    func testSetPagination() {
        let viewModel = createViewModel()
        
        viewModel.currentPage = 3
        viewModel.hasMoreData = false
        viewModel.totalCount = 150
        
        #expect(viewModel.currentPage == 3)
        #expect(viewModel.hasMoreData == false)
        #expect(viewModel.totalCount == 150)
    }
}
