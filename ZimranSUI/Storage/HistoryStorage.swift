//
//  HistoryStorage.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

class HistoryStorage {
    static let shared = HistoryStorage()
    
    private let userDefaults = UserDefaults.standard
    private let repositoryHistoryKey = "repository_history"
    private let userHistoryKey = "user_history"
    private let maxHistoryItems = 20
    
    private init() {}
    
    // MARK: - Repository History
    
    func addRepositoryToHistory(_ repository: Repository) {
        let historyItem = HistoryItem(repository: repository)
        var history = getRepositoryHistory()
        
        // Remove existing item if it exists
        history.removeAll { $0.id == historyItem.id }
        
        // Add new item at the beginning
        history.insert(historyItem, at: 0)
        
        // Keep only the last 20 items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveRepositoryHistory(history)
    }
    
    func getRepositoryHistory() -> [HistoryItem] {
        guard let data = userDefaults.data(forKey: repositoryHistoryKey),
              let history = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    private func saveRepositoryHistory(_ history: [HistoryItem]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: repositoryHistoryKey)
        }
    }
    
    // MARK: - User History
    
    func addUserToHistory(_ user: User) {
        let historyItem = HistoryItem(user: user)
        var history = getUserHistory()
        
        // Remove existing item if it exists
        history.removeAll { $0.id == historyItem.id }
        
        // Add new item at the beginning
        history.insert(historyItem, at: 0)
        
        // Keep only the last 20 items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveUserHistory(history)
    }
    
    func getUserHistory() -> [HistoryItem] {
        guard let data = userDefaults.data(forKey: userHistoryKey),
              let history = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    private func saveUserHistory(_ history: [HistoryItem]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: userHistoryKey)
        }
    }
    
    // MARK: - Clear History
    
    func clearRepositoryHistory() {
        userDefaults.removeObject(forKey: repositoryHistoryKey)
    }
    
    func clearUserHistory() {
        userDefaults.removeObject(forKey: userHistoryKey)
    }
}
