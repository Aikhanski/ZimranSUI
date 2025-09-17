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
    func deleteRepositoryHistoryItem(_ id: String)
    func deleteUserHistoryItem(_ id: String)
}

// MARK: - History Storage Manager
final class HistoryStorageManager: HistoryStorageProvider {
    @FileStorage(path: "repository_history")
    private var repositoryHistory: [HistoryItem]?
    
    @FileStorage(path: "user_history")
    private var userHistory: [HistoryItem]?
    
    // Кэш в памяти для мгновенного доступа
    private var cachedRepositoryHistory: [HistoryItem] = []
    private var cachedUserHistory: [HistoryItem] = []
    
    private let maxHistoryItems = 20
    
    init() {
        // Загружаем кэш при инициализации
        loadCacheFromStorage()
    }
    
    private func loadCacheFromStorage() {
        // Синхронно загружаем из @FileStorage
        cachedRepositoryHistory = repositoryHistory ?? []
        cachedUserHistory = userHistory ?? []
    }
    
    private func syncCacheToStorage() {
        // Принудительно синхронизируем кэш с файловым хранилищем
        repositoryHistory = cachedRepositoryHistory
        userHistory = cachedUserHistory
    }
    
    func addRepositoryToHistory(_ repository: RepositoryModel) {
        let historyItem = HistoryItem(repository: repository)
        
        // Обновляем кэш в памяти мгновенно
        cachedRepositoryHistory.removeAll { $0.id == historyItem.id }
        cachedRepositoryHistory.insert(historyItem, at: 0)
        
        if cachedRepositoryHistory.count > maxHistoryItems {
            cachedRepositoryHistory = Array(cachedRepositoryHistory.prefix(maxHistoryItems))
        }
        
        
        // Синхронизируем с файловым хранилищем
        syncCacheToStorage()
        
        // Отправляем уведомление об обновлении истории
        NotificationCenter.default.post(name: .historyUpdated, object: nil)
    }
    
    func addUserToHistory(_ user: UserModel) {
        let historyItem = HistoryItem(user: user)
        
        // Обновляем кэш в памяти мгновенно
        cachedUserHistory.removeAll { $0.id == historyItem.id }
        cachedUserHistory.insert(historyItem, at: 0)

        if cachedUserHistory.count > maxHistoryItems {
            cachedUserHistory = Array(cachedUserHistory.prefix(maxHistoryItems))
        }
        
        // Синхронизируем с файловым хранилищем
        syncCacheToStorage()
        
        // Отправляем уведомление об обновлении истории
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
