//
//  GitHubRepositoryRequestFactory.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

// MARK: - Request Factory
enum GitHubRepositoryRequestFactory {
    case searchRepositories(parameters: RepositorySearchParameters)
    
    var urlRequest: URLRequest {
        switch self {
        case .searchRepositories(let parameters):
            return createSearchRepositoriesRequest(parameters: parameters)
        }
    }
    
    private func createSearchRepositoriesRequest(parameters: RepositorySearchParameters) -> URLRequest {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: parameters.query),
            URLQueryItem(name: "per_page", value: "\(parameters.perPage)"),
            URLQueryItem(name: "page", value: "\(parameters.page)")
        ]
        
        // Add sort and order parameters only if not best match
        if parameters.sort != .bestMatch {
            queryItems.append(URLQueryItem(name: "sort", value: parameters.sort.rawValue))
            queryItems.append(URLQueryItem(name: "order", value: parameters.order.rawValue))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        // Add required headers
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        // Add authorization header if token is available
        if let token = GitHubTokenManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
