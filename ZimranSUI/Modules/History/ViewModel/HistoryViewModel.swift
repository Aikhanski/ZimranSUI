//
//  HistoryViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine
import UIKit

final class HistoryViewModel: ObservableObject {
    @Published var repositoryHistory: [HistoryItem] = []
    @Published var userHistory: [HistoryItem] = []
    @Published var selectedTab: HistoryTab = .repositories
    @Published var isRefreshing = false
    
    private let historyStorageProvider: HistoryStorageProvider
    private let router: any RouterProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        historyStorageProvider: HistoryStorageProvider,
        router: any RouterProtocol
    ) {
        self.historyStorageProvider = historyStorageProvider
        self.router = router
        loadHistory()
    }
    
    convenience init() {
        self.init(
            historyStorageProvider: DependencyContainer.shared.resolve(HistoryStorageProvider.self)!,
            router: DependencyContainer.shared.resolve((any RouterProtocol).self)!
        )
    }
    
    enum HistoryTab: CaseIterable {
        case repositories
        case users
        
        var title: String {
            switch self {
            case .repositories:
                return "Repositories"
            case .users:
                return "Users"
            }
        }
    }
    
    func loadHistory() {
        repositoryHistory = historyStorageProvider.getRepositoryHistory()
        userHistory = historyStorageProvider.getUserHistory()
    }
    
    @MainActor
    func refreshHistory() async {
        isRefreshing = true
        loadHistory()
        isRefreshing = false
    }
    
    func clearRepositoryHistory() {
        historyStorageProvider.clearRepositoryHistory()
        repositoryHistory = []
    }
    
    func clearUserHistory() {
        historyStorageProvider.clearUserHistory()
        userHistory = []
    }
    
    func selectRepository(_ repository: RepositoryModel) {
        if let url = URL(string: repository.htmlUrl) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func selectUser(_ user: UserModel) {
        router.showUserRepositories()
    }
    
    func switchTab(_ tab: HistoryTab) {
        selectedTab = tab
    }
}
