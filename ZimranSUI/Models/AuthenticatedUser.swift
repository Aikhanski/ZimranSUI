//
//  AuthenticatedUser.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

struct AuthenticatedUser: Codable {
    let id: Int
    let login: String
    let avatarURL: String
    let htmlURL: String
    let name: String?
    let email: String?
    let bio: String?
    let company: String?
    let blog: String?
    let location: String?
    let type: String
    let siteAdmin: Bool
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    let publicGists: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, email, bio, company, blog, location, type
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
