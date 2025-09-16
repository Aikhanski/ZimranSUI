//
//  History.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let url: String
    let timestamp: Date
    let type: HistoryType
    
    init(repository: Repository) {
        self.id = "repo_\(repository.id)"
        self.title = repository.name
        self.subtitle = repository.owner.login
        self.url = repository.htmlURL
        self.timestamp = Date()
        self.type = .repository
    }
    
    init(user: User) {
        self.id = "user_\(user.id)"
        self.title = user.login
        self.subtitle = "\(user.followers ?? 0) followers"
        self.url = user.htmlURL
        self.timestamp = Date()
        self.type = .user
    }
}

enum HistoryType: String, Codable {
    case repository = "repository"
    case user = "user"
}
