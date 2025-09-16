//
//  Repository.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

struct Repository: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlURL: String
    let cloneURL: String?
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let updatedAt: String
    let createdAt: String
    let owner: RepositoryOwner
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case fullName = "full_name"
        case htmlURL = "html_url"
        case cloneURL = "clone_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case owner
    }
}

struct RepositoryOwner: Codable, Hashable {
    let id: Int
    let login: String
    let avatarURL: String
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

struct RepositorySearchResponse: Codable {
    let totalCount: Int
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

enum RepositorySortType: String, CaseIterable {
    case stars = "stars"
    case updated = "updated"
    case forks = "forks"
    
    var displayName: String {
        switch self {
        case .stars:
            return "Stars"
        case .updated:
            return "Updated"
        case .forks:
            return "Forks"
        }
    }
}
