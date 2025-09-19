//
//  RepositorySearchViewModelTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Testing
import Combine
import Foundation
@testable import ZimranSUI

@Suite(.serialized)
struct RepositorySearchViewModelTests: MockInjector {
    
    private func createViewModel() -> RepositorySearchViewModel {
        let mockGitHubRepositoryProvider = injectedMock(for: GitHubRepositoryProvider.self)
        let mockHistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter = injectedMock(for: (any RouterProtocol).self)
        
        return RepositorySearchViewModel(
            githubRepositoryProvider: mockGitHubRepositoryProvider,
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )
    }
    
    @Test("Инициализация RepositorySearchViewModel")
    func testInitialization() {
        let viewModel = createViewModel()

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
    
    @Test("Поиск репозиториев с пустым запросом")
    func testSearchWithEmptyQuery() {
        let viewModel = createViewModel()

        viewModel.searchText = ""
        viewModel.search()

        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.totalCount == 0)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.hasMoreData)
    }
    
    @Test("Изменение опции сортировки")
    func testChangeSortOption() {
        let viewModel = createViewModel()
        viewModel.changeSortOption(.stars)

        #expect(viewModel.sortOption == .stars)
    }
    
    @Test("Переключение порядка сортировки")
    func testToggleSortOrder() {
        let viewModel = createViewModel()
        let initialOrder = viewModel.sortOrder

        viewModel.toggleSortOrder()

        #expect(viewModel.sortOrder != initialOrder)
        #expect(viewModel.sortOrder == .asc)

        viewModel.toggleSortOrder()
        #expect(viewModel.sortOrder == initialOrder)
    }

    @Test("Загрузка дополнительных данных когда нет больше данных")
    func testLoadMoreDataWhenNoMoreData() {
        let viewModel = createViewModel()
        viewModel.hasMoreData = false
        viewModel.isLoading = false
        
        viewModel.loadMoreData()

        #expect(viewModel.currentPage == 1)
    }
}
