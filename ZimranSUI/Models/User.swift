//
//  User.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let login: String
    let avatarURL: String
    let htmlURL: String
    let type: String
    let siteAdmin: Bool
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    let publicGists: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, type
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
        case siteAdmin = "site_admin"
        case followers, following
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserSearchResponse: Codable {
    let totalCount: Int
    let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

enum UserSortType: String, CaseIterable {
    case followers = "followers"
    case repositories = "repositories"
    case joined = "joined"
    
    var displayName: String {
        switch self {
        case .followers:
            return "Followers"
        case .repositories:
            return "Repositories"
        case .joined:
            return "Joined"
        }
    }
}
