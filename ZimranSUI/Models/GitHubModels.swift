//
//  GitHubModels.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

//
//

import Foundation

struct RepositoryModel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let htmlUrl: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let updatedAt: Date
    let createdAt: Date?
    let language: String?
    let owner: OwnerModel
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, owner, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
    
    init(
        id: Int,
        name: String,
        fullName: String,
        htmlUrl: String,
        description: String?,
        stargazersCount: Int,
        forksCount: Int,
        updatedAt: Date,
        createdAt: Date?,
        language: String?,
        owner: OwnerModel
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.htmlUrl = htmlUrl
        self.description = description
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.language = language
        self.owner = owner
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fullName = try container.decode(String.self, forKey: .fullName)
        htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        forksCount = try container.decode(Int.self, forKey: .forksCount)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        owner = try container.decode(OwnerModel.self, forKey: .owner)
        
        // Custom date decoding
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = try Self.dateFormatter.date(from: updatedAtString) ?? Date()
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = Self.dateFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}

struct OwnerModel: Codable, Hashable {
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    
    init(login: String, avatarUrl: String, htmlUrl: String) {
        self.login = login
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

struct SearchRepositoriesResponse: Codable {
    let totalCount: Int
    let items: [RepositoryModel]
    let incompleteResults: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
        case incompleteResults = "incomplete_results"
    }
}

struct UserModel: Codable, Identifiable, Hashable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let type: String
    let siteAdmin: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, login, type
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case siteAdmin = "site_admin"
    }
}

struct SearchUsersResponse: Codable {
    let totalCount: Int
    let items: [UserModel]
    let incompleteResults: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
        case incompleteResults = "incomplete_results"
    }
}

struct RepositorySearchParameters: Encodable {
    let query: String
    let sort: RepositorySortOption
    let order: SortOrder
    let perPage: Int
    let page: Int
    
    init(
        query: String,
        sort: RepositorySortOption = .bestMatch,
        order: SortOrder = .desc,
        perPage: Int = 30,
        page: Int = 1
    ) {
        self.query = query
        self.sort = sort
        self.order = order
        self.perPage = perPage
        self.page = page
    }
}

struct UserSearchParameters: Encodable {
    let query: String
    let sort: UserSortOption
    let order: SortOrder
    let perPage: Int
    let page: Int
    
    init(
        query: String,
        sort: UserSortOption = .bestMatch,
        order: SortOrder = .desc,
        perPage: Int = 30,
        page: Int = 1
    ) {
        self.query = query
        self.sort = sort
        self.order = order
        self.perPage = perPage
        self.page = page
    }
}

enum RepositorySortOption: String, CaseIterable, Codable {
    case stars
    case forks
    case updated
    case bestMatch = ""
    
    var displayName: String {
        switch self {
        case .stars:
            return "Stars"
        case .forks:
            return "Forks"
        case .updated:
            return "Updated"
        case .bestMatch:
            return "Best Match"
        }
    }
}

enum UserSortOption: String, CaseIterable, Codable {
    case followers
    case repositories
    case joined
    case bestMatch = ""
    
    var displayName: String {
        switch self {
        case .followers:
            return "Followers"
        case .repositories:
            return "Repositories"
        case .joined:
            return "Joined"
        case .bestMatch:
            return "Best Match"
        }
    }
}

enum SortOrder: String, CaseIterable, Codable {
    case asc
    case desc
    
    var displayName: String {
        switch self {
        case .asc:
            return "Ascending"
        case .desc:
            return "Descending"
        }
    }
}
