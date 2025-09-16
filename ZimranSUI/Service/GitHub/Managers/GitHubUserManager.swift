//
//  GitHubUserManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

final class GitHubUserManager: GitHubUserProvider {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func searchUsers(query: String, sort: UserSortOption, order: SortOrder) -> AnyPublisher<SearchUsersResponse, Error> {
        var parameters = ["q": query]
        
        // Добавляем параметры сортировки только если не best match
        if sort != .bestMatch {
            parameters["sort"] = sort.rawValue
            parameters["order"] = order.rawValue
        }
        
        return networkClient.get("/search/users", parameters: parameters)
    }
    
    func getUser(username: String) -> AnyPublisher<UserModel, Error> {
        let path = "/users/\(username)"
        return networkClient.get(path)
    }
    
    func getAuthenticatedUser() -> AnyPublisher<AuthenticatedUser, Error> {
        let path = "/user"
        return networkClient.get(path)
    }
}
