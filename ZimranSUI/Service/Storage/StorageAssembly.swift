//
//  StorageAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

extension Notification.Name {
    static let historyUpdated = Notification.Name("historyUpdated")
}

struct StorageAssembly: Assembly {
    func assemble(container: Container) {
        container.register(HistoryStorageProvider.self) { _ in
            HistoryStorageManager()
        }
    }
}

// MARK: - History Storage Protocol
protocol HistoryStorageProvider {
    func addRepositoryToHistory(_ repository: RepositoryModel)
    func addUserToHistory(_ user: UserModel)
    func getRepositoryHistory() -> [HistoryItem]
    func getUserHistory() -> [HistoryItem]
    func clearRepositoryHistory()
    func clearUserHistory()
}

// MARK: - History Storage Manager
final class HistoryStorageManager: HistoryStorageProvider {
    @FileStorage(path: "repository_history")
    private var repositoryHistory: [HistoryItem]?
    
    @FileStorage(path: "user_history")
    private var userHistory: [HistoryItem]?
    
    private let maxHistoryItems = 20
    
    func addRepositoryToHistory(_ repository: RepositoryModel) {
        
        let historyItem = HistoryItem(repository: repository)
        
        var currentHistory = repositoryHistory ?? []
        currentHistory.removeAll { $0.id == historyItem.id }
        currentHistory.insert(historyItem, at: 0)
        
        if currentHistory.count > maxHistoryItems {
            currentHistory = Array(currentHistory.prefix(maxHistoryItems))
        }
        
        repositoryHistory = currentHistory
        
        // Отправляем уведомление об обновлении истории
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func addUserToHistory(_ user: UserModel) {
        let historyItem = HistoryItem(user: user)
        
        var currentHistory = userHistory ?? []
        currentHistory.removeAll { $0.id == historyItem.id }
        currentHistory.insert(historyItem, at: 0)

        if currentHistory.count > maxHistoryItems {
            currentHistory = Array(currentHistory.prefix(maxHistoryItems))
        }
        
        userHistory = currentHistory
        
        // Отправляем уведомление об обновлении истории
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func getRepositoryHistory() -> [HistoryItem] {
        let history = repositoryHistory ?? []
        return history
    }
    
    func getUserHistory() -> [HistoryItem] {
        return userHistory ?? []
    }
    
    func clearRepositoryHistory() {
        repositoryHistory = []
    }
    
    func clearUserHistory() {
        userHistory = []
    }
}
