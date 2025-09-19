//
//  HistoryViewModelTests.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Testing
import Combine
import Foundation
@testable import ZimranSUI

@Suite(.serialized)
struct HistoryViewModelTests: MockInjector {
    
    private func createViewModel() -> HistoryViewModel {
        let mockHistoryStorageProvider = injectedMock(for: HistoryStorageProvider.self)
        let mockRouter = injectedMock(for: (any RouterProtocol).self)
        
        return HistoryViewModel(
            historyStorageProvider: mockHistoryStorageProvider,
            router: mockRouter
        )
    }
    
    // MARK: - Тесты переключения вкладок
    
    @Test("Переключение вкладок")
    func testSwitchTab() {
        let viewModel = createViewModel()

        viewModel.switchTab(.users)
        #expect(viewModel.selectedTab == .users)

        viewModel.switchTab(.repositories)
        #expect(viewModel.selectedTab == .repositories)
    }
    
    // MARK: - Тесты состояния загрузки
    
    @Test("Проверка начального состояния загрузки")
    func testInitialRefreshingState() {
        let viewModel = createViewModel()
        #expect(viewModel.isRefreshing == false)
    }
    
    // MARK: - Тесты инициализации
    
    @Test("Инициализация HistoryViewModel")
    func testInitialization() {
        let viewModel = createViewModel()

        #expect(viewModel.repositoryHistory.isEmpty)
        #expect(viewModel.userHistory.isEmpty)
        #expect(viewModel.selectedTab == .repositories)
        #expect(!viewModel.isRefreshing)
    }
    
    // MARK: - Тесты очистки истории
    
    @Test("Очистка истории репозиториев")
    func testClearRepositoryHistory() {
        let viewModel = createViewModel()
        viewModel.repositoryHistory = [
            HistoryItem(id: "repo_1", title: "swift", subtitle: "owner", url: "https://github.com/owner/swift", timestamp: Date().addingTimeInterval(-3600), type: .repository),
            HistoryItem(id: "repo_2", title: "ios", subtitle: "owner", url: "https://github.com/owner/ios", timestamp: Date().addingTimeInterval(-7200), type: .repository)
        ]
        viewModel.clearRepositoryHistory()
        
        #expect(viewModel.repositoryHistory.isEmpty)
    }
    
    @Test("Очистка истории пользователей")
    func testClearUserHistory() {
        let viewModel = createViewModel()
        viewModel.userHistory = [
            HistoryItem(id: "user_1", title: "john", subtitle: "GitHub User", url: "https://github.com/john", timestamp: Date().addingTimeInterval(-1800), type: .user),
            HistoryItem(id: "user_2", title: "jane", subtitle: "GitHub User", url: "https://github.com/jane", timestamp: Date().addingTimeInterval(-5400), type: .user)
        ]
        viewModel.clearUserHistory()
        
        #expect(viewModel.userHistory.isEmpty)
    }
}
