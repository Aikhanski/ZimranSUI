//
//  NetworkTarget.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

protocol NetworkTarget {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum GitHubAPI: NetworkTarget {
    case authenticate(username: String, password: String)
    case searchRepositories(query: String, sort: String?, order: String?, page: Int, perPage: Int)
    case searchUsers(query: String, sort: String?, order: String?, page: Int, perPage: Int)
    case getUserRepositories(username: String, sort: String?, page: Int, perPage: Int)
    
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .authenticate:
            return "/user"
        case .searchRepositories:
            return "/search/repositories"
        case .searchUsers:
            return "/search/users"
        case .getUserRepositories(let username, _, _, _):
            return "/users/\(username)/repos"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .authenticate:
            return .get
        case .searchRepositories, .searchUsers, .getUserRepositories:
            return .get
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .authenticate(let username, let password):
            // Для Personal Access Token используем Bearer, для username/password - Basic
            if username.isEmpty && !password.isEmpty {
                // Personal Access Token
                return [
                    "Authorization": "Bearer \(password)",
                    "Accept": "application/vnd.github+json",
                    "X-GitHub-Api-Version": "2022-11-28"
                ]
            } else {
                // Username/Password Basic Auth
                let credentials = "\(username):\(password)"
                let data = credentials.data(using: .utf8)!
                let base64Credentials = data.base64EncodedString()
                return [
                    "Authorization": "Basic \(base64Credentials)",
                    "Accept": "application/vnd.github+json",
                    "X-GitHub-Api-Version": "2022-11-28"
                ]
            }
        default:
            return [
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": "2022-11-28"
            ]
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .authenticate:
            return nil
        case .searchRepositories(let query, let sort, let order, let page, let perPage):
            var params: [String: Any] = [
                "q": query,
                "page": page,
                "per_page": perPage
            ]
            if let sort = sort {
                params["sort"] = sort
            }
            if let order = order {
                params["order"] = order
            }
            return params
        case .searchUsers(let query, let sort, let order, let page, let perPage):
            var params: [String: Any] = [
                "q": query,
                "page": page,
                "per_page": perPage
            ]
            if let sort = sort {
                params["sort"] = sort
            }
            if let order = order {
                params["order"] = order
            }
            return params
        case .getUserRepositories(_, let sort, let page, let perPage):
            var params: [String: Any] = [
                "page": page,
                "per_page": perPage
            ]
            if let sort = sort {
                params["sort"] = sort
            }
            return params
        }
    }
}
