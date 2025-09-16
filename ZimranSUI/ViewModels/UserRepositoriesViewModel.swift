//
//  UserRepositoriesViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

class UserRepositoriesViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortType: RepositorySortType = .stars
    @Published var currentPage: Int = 1
    @Published var hasMoreData: Bool = true
    
    private let networkProvider: NetworkProvider
    private let historyStorage: HistoryStorage
    private var cancellables = Set<AnyCancellable>()
    private let itemsPerPage = 30
    private let username: String
    
    init(username: String,
         networkProvider: NetworkProvider = NetworkProvider.shared,
         historyStorage: HistoryStorage = HistoryStorage.shared) {
        self.username = username
        self.networkProvider = networkProvider
        self.historyStorage = historyStorage
    }
    
    func loadRepositories() {
        currentPage = 1
        hasMoreData = true
        fetchRepositories()
    }
    
    func loadMoreData() {
        guard hasMoreData && !isLoading else { return }
        
        currentPage += 1
        fetchRepositories(append: true)
    }
    
    func changeSortType(_ sortType: RepositorySortType) {
        self.sortType = sortType
        if !repositories.isEmpty {
            loadRepositories()
        }
    }
    
    func selectRepository(_ repository: Repository) {
        historyStorage.addRepositoryToHistory(repository)
    }
    
    private func fetchRepositories(append: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let target = GitHubAPI.getUserRepositories(
            username: username,
            sort: sortType.rawValue,
            page: currentPage,
            perPage: itemsPerPage
        )
        
        networkProvider.request(target, responseType: [Repository].self)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.getErrorMessage(for: error)
                    }
                },
                receiveValue: { [weak self] repositories in
                    if append {
                        self?.repositories.append(contentsOf: repositories)
                    } else {
                        self?.repositories = repositories
                    }
                    self?.hasMoreData = repositories.count == self?.itemsPerPage
                }
            )
            .store(in: &cancellables)
    }
    
    private func getErrorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
