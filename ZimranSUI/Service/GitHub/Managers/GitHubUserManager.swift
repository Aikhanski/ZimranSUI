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
    
    func searchUsers(query: String) -> AnyPublisher<SearchUsersResponse, Error> {
        let parameters = ["q": query]
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
