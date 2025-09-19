//
//  SimpleTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 19.09.2025.
//

import Testing
import Foundation
import Combine
@testable import ZimranSUI

@Suite(.serialized)
struct SimpleTests: MockInjector {
    
    @Test("Простая инициализация HistoryViewModel")
    func testHistoryViewModelInitialization() {

        let mockHistoryStorageProvider: HistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter: any RouterProtocol = injectedMock(for: (any RouterProtocol).self)

        let viewModel = HistoryViewModel(
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )

        #expect(viewModel.repositoryHistory.isEmpty)
        #expect(viewModel.userHistory.isEmpty)
        #expect(viewModel.selectedTab == .repositories)
        #expect(!viewModel.isRefreshing)
    }
    
    @Test("Переключение вкладок в HistoryViewModel")
    func testHistoryViewModelSwitchTab() {

        let mockHistoryStorageProvider: HistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter: any RouterProtocol = injectedMock(for: (any RouterProtocol).self)
        let viewModel = HistoryViewModel(
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )

        viewModel.selectedTab = .users

        #expect(viewModel.selectedTab == .users)
    }
    
    // MARK: - Simple SearchViewModel Tests
    
    @Test("Простая инициализация SearchViewModel")
    func testSearchViewModelInitialization() {
        let mockGitHubUserProvider: GitHubUserProvider = injectedMock(for: GitHubUserProvider.self)
        let mockHistoryStorageProvider: HistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter: any RouterProtocol = injectedMock(for: (any RouterProtocol).self)

        let viewModel = SearchViewModel(
            githubUserProvider: mockGitHubUserProvider,
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )

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
    
    @Test("Установка текста поиска в SearchViewModel")
    func testSearchViewModelSetSearchText() {
        // Arrange
        let mockGitHubUserProvider: GitHubUserProvider = injectedMock(for: GitHubUserProvider.self)
        let mockHistoryStorageProvider: HistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter: any RouterProtocol = injectedMock(for: (any RouterProtocol).self)
        let viewModel = SearchViewModel(
            githubUserProvider: mockGitHubUserProvider,
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )

        viewModel.searchText = "test"

        #expect(viewModel.searchText == "test")
    }
    
    @Test("Простая инициализация RepositorySearchViewModel")
    func testRepositorySearchViewModelInitialization() {
        let mockGitHubRepositoryProvider: GitHubRepositoryProvider = injectedMock(for: GitHubRepositoryProvider.self)
        let mockHistoryStorageProvider: HistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter: any RouterProtocol = injectedMock(for: (any RouterProtocol).self)

        let viewModel = RepositorySearchViewModel(
            githubRepositoryProvider: mockGitHubRepositoryProvider,
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.repositories.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.showError)
        #expect(viewModel.sortOption == .bestMatch)
        #expect(viewModel.sortOrder == .desc)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.hasMoreData)
        #expect(viewModel.totalCount == 0)
    }
    
    @Test("Создание UserModel")
    func testUserModelCreation() {
        let user = UserModel(
            id: 1,
            login: "testuser",
            avatarUrl: "https://example.com/avatar.png",
            htmlUrl: "https://github.com/testuser",
            type: "User",
            siteAdmin: false
        )

        #expect(user.id == 1)
        #expect(user.login == "testuser")
        #expect(user.type == "User")
        #expect(!user.siteAdmin)
    }
    
    @Test("Создание HistoryItem")
    func testHistoryItemCreation() {
        let historyItem = HistoryItem(
            id: "1",
            title: "test-repo",
            subtitle: "Test repository",
            url: "https://github.com/testuser/test-repo",
            timestamp: Date(),
            type: .repository
        )

        #expect(historyItem.id == "1")
        #expect(historyItem.title == "test-repo")
        #expect(historyItem.type == .repository)
        #expect(historyItem.url == "https://github.com/testuser/test-repo")
    }
    
    @Test("Тест HistoryTab enum")
    func testHistoryTabEnum() {
        #expect(HistoryViewModel.HistoryTab.repositories.title == "Repositories")
        #expect(HistoryViewModel.HistoryTab.users.title == "Users")
    }
    
    @Test("Тест UserSortOption enum")
    func testUserSortOptionEnum() {
        #expect(UserSortOption.bestMatch.rawValue == "")
        #expect(UserSortOption.followers.rawValue == "followers")
        #expect(UserSortOption.repositories.rawValue == "repositories")
        #expect(UserSortOption.joined.rawValue == "joined")
    }
    
    @Test("Тест SortOrder enum")
    func testSortOrderEnum() {
        #expect(SortOrder.asc.rawValue == "asc")
        #expect(SortOrder.desc.rawValue == "desc")
    }
}

