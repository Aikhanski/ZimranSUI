//
//  GitHubRepositorySearchService.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

// MARK: - Service Protocol
protocol GitHubRepositorySearchService {
    func searchRepositories(
        parameters: RepositorySearchParameters
    ) -> AnyPublisher<SearchRepositoriesResponse, Error>
    
    func searchRepositories(
        parameters: RepositorySearchParameters,
        completion: @escaping (Result<SearchRepositoriesResponse, Error>) -> Void
    )
}

// MARK: - Service Implementation
final class GitHubRepositorySearchServiceImpl: GitHubRepositorySearchService {
    private let session: URLSession
    private let requestFactory: GitHubRepositoryRequestFactory.Type
    
    init(
        session: URLSession = .shared,
        requestFactory: GitHubRepositoryRequestFactory.Type = GitHubRepositoryRequestFactory.self
    ) {
        self.session = session
        self.requestFactory = requestFactory
    }
    
    // MARK: - Combine Publisher
    func searchRepositories(
        parameters: RepositorySearchParameters
    ) -> AnyPublisher<SearchRepositoriesResponse, Error> {
        let request = requestFactory.searchRepositories(parameters: parameters).urlRequest
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SearchRepositoriesResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return GitHubAPIError.decodingError(error)
                } else {
                    return GitHubAPIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Completion Handler
    func searchRepositories(
        parameters: RepositorySearchParameters,
        completion: @escaping (Result<SearchRepositoriesResponse, Error>) -> Void
    ) {
        let request = requestFactory.searchRepositories(parameters: parameters).urlRequest
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(GitHubAPIError.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(GitHubAPIError.invalidResponse))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(GitHubAPIError.serverError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(GitHubAPIError.noData))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(SearchRepositoriesResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(GitHubAPIError.decodingError(error)))
                }
            }
        }.resume()
    }
}

// MARK: - API Errors
enum GitHubAPIError: Error, LocalizedError {
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case invalidResponse
    case noData
    case invalidURL
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            if code == 403 {
                return "Rate limit exceeded. Please try again later."
            }
            return "Server error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received from server"
        case .invalidURL:
            return "Invalid URL"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        }
    }
}
