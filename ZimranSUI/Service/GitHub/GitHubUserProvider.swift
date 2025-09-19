//
//  GitHubUserProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 16.09.2025.
//

import Foundation
import Combine

protocol GitHubUserProvider {
    func searchUsers(query: String, sort: UserSortOption, order: SortOrder) -> AnyPublisher<SearchUsersResponse, Error>
    func getUser(username: String) -> AnyPublisher<UserModel, Error>
    func getAuthenticatedUser() -> AnyPublisher<AuthenticatedUser, Error>
}
