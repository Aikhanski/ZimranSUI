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
    
    private let historyStorageProvider = DependencyContainer.shared.resolve(HistoryStorageProvider.self)!
    private let router = DependencyContainer.shared.resolve(Router.self)!
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        loadHistory()
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
            UIApplication.shared.open(url)
        }
    }
    
    func selectUser(_ user: UserModel) {
        router.showUserRepositories()
    }
    
    func switchTab(_ tab: HistoryTab) {
        selectedTab = tab
    }
}
