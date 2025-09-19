//
//  StorageAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 16.09.2025.
//

//
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

protocol HistoryStorageProvider {
    func addRepositoryToHistory(_ repository: RepositoryModel)
    func addUserToHistory(_ user: UserModel)
    func getRepositoryHistory() -> [HistoryItem]
    func getUserHistory() -> [HistoryItem]
    func clearRepositoryHistory()
    func clearUserHistory()
    func deleteRepositoryHistoryItem(_ id: String)
    func deleteUserHistoryItem(_ id: String)
}

final class HistoryStorageManager: HistoryStorageProvider {
    @FileStorage(path: "repository_history")
    private var repositoryHistory: [HistoryItem]?
    
    @FileStorage(path: "user_history")
    private var userHistory: [HistoryItem]?
    
    private var cachedRepositoryHistory: [HistoryItem] = []
    private var cachedUserHistory: [HistoryItem] = []
    
    private let maxHistoryItems = 20
    
    init() {
        loadCacheFromStorage()
    }
    
    private func loadCacheFromStorage() {
        cachedRepositoryHistory = repositoryHistory ?? []
        cachedUserHistory = userHistory ?? []
    }
    
    private func syncCacheToStorage() {
        repositoryHistory = cachedRepositoryHistory
        userHistory = cachedUserHistory
    }
    
    func addRepositoryToHistory(_ repository: RepositoryModel) {
        let historyItem = HistoryItem(repository: repository)
        
        cachedRepositoryHistory.removeAll { $0.id == historyItem.id }
        cachedRepositoryHistory.insert(historyItem, at: 0)
        
        if cachedRepositoryHistory.count > maxHistoryItems {
            cachedRepositoryHistory = Array(cachedRepositoryHistory.prefix(maxHistoryItems))
        }
        
        
        syncCacheToStorage()
        
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func addUserToHistory(_ user: UserModel) {
        let historyItem = HistoryItem(user: user)
        
        cachedUserHistory.removeAll { $0.id == historyItem.id }
        cachedUserHistory.insert(historyItem, at: 0)

        if cachedUserHistory.count > maxHistoryItems {
            cachedUserHistory = Array(cachedUserHistory.prefix(maxHistoryItems))
        }
        
        syncCacheToStorage()
        
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func getRepositoryHistory() -> [HistoryItem] {
        return cachedRepositoryHistory
    }
    
    func getUserHistory() -> [HistoryItem] {
        return cachedUserHistory
    }
    
    func clearRepositoryHistory() {
        cachedRepositoryHistory = []
        syncCacheToStorage()
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func clearUserHistory() {
        cachedUserHistory = []
        syncCacheToStorage()
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func deleteRepositoryHistoryItem(_ id: String) {
        cachedRepositoryHistory.removeAll { $0.id == id }
        syncCacheToStorage()
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func deleteUserHistoryItem(_ id: String) {
        cachedUserHistory.removeAll { $0.id == id }
        syncCacheToStorage()
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
}
