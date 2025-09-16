//
//  History.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

struct HistoryItem: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let url: String
    let timestamp: Date
    let type: HistoryType
    
    init(repository: RepositoryModel) {
        self.id = "repo_\(repository.id)"
        self.title = repository.name
        self.subtitle = repository.owner.login
        self.url = repository.htmlUrl
        self.timestamp = Date()
        self.type = .repository
    }
    
    init(user: UserModel) {
        self.id = "user_\(user.id)"
        self.title = user.login
        self.subtitle = "GitHub User"
        self.url = user.htmlUrl
        self.timestamp = Date()
        self.type = .user
    }
    
    // Manual init for Codable
    init(id: String, title: String, subtitle: String, url: String, timestamp: Date, type: HistoryType) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.timestamp = timestamp
        self.type = type
    }
}

enum HistoryType: String, Codable {
    case repository = "repository"
    case user = "user"
}
