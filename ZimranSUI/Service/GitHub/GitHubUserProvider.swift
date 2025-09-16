//
//  GitHubUserProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

protocol GitHubUserProvider {
    func searchUsers(query: String) -> AnyPublisher<SearchUsersResponse, Error>
    func getUser(username: String) -> AnyPublisher<UserModel, Error>
    func getAuthenticatedUser() -> AnyPublisher<AuthenticatedUser, Error>
}
