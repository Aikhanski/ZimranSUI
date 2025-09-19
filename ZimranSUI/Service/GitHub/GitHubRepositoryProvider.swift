//
//  GitHubRepositoryProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 16.09.2025.
//

import Foundation
import Combine

protocol GitHubRepositoryProvider {
    func searchRepositories(
        parameters: RepositorySearchParameters
    ) -> AnyPublisher<SearchRepositoriesResponse, Error>
    func getUserRepositories(username: String) -> AnyPublisher<[RepositoryModel], Error>
}
