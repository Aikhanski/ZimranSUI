//
//  HistoryViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var repositoryHistory: [HistoryItem] = []
    @Published var userHistory: [HistoryItem] = []
    @Published var selectedTab: HistoryTab = .repositories
    
    private let historyStorage: HistoryStorage
    
    enum HistoryTab: String, CaseIterable {
        case repositories = "Repositories"
        case users = "Users"
    }
    
    init(historyStorage: HistoryStorage = HistoryStorage.shared) {
        self.historyStorage = historyStorage
        loadHistory()
    }
    
    func loadHistory() {
        repositoryHistory = historyStorage.getRepositoryHistory()
        userHistory = historyStorage.getUserHistory()
    }
    
    func clearRepositoryHistory() {
        historyStorage.clearRepositoryHistory()
        repositoryHistory = []
    }
    
    func clearUserHistory() {
        historyStorage.clearUserHistory()
        userHistory = []
    }
    
    func switchTab(_ tab: HistoryTab) {
        selectedTab = tab
    }
}
