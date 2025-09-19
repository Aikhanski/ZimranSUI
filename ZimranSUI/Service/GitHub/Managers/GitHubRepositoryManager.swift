//
//  GitHubRepositoryManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 16.09.2025.
//

import Foundation
import Combine

final class GitHubRepositoryManager: GitHubRepositoryProvider {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func searchRepositories(
        parameters: RepositorySearchParameters
    ) -> AnyPublisher<SearchRepositoriesResponse, Error> {
        var queryParams: [String: String] = [
            "q": parameters.query,
            "per_page": "\(parameters.perPage)",
            "page": "\(parameters.page)"
        ]
    
        if parameters.sort != .bestMatch {
            queryParams["sort"] = parameters.sort.rawValue
            queryParams["order"] = parameters.order.rawValue
        }
        return networkClient.get("/search/repositories", parameters: queryParams)
    }
    
    func getUserRepositories(username: String) -> AnyPublisher<[RepositoryModel], Error> {
        return networkClient.get("/users/\(username)/repos")
    }
}
