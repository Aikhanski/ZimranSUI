//
//  RepositorySearchService.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

protocol RepositorySearchServiceProtocol {
    func searchRepositories(
        query: String,
        sortOption: RepositorySortOption,
        sortOrder: SortOrder,
        page: Int
    ) -> AnyPublisher<SearchRepositoriesResponse, Error>
}

final class RepositorySearchService: RepositorySearchServiceProtocol {
    
    private let githubRepositoryProvider: GitHubRepositoryProvider
    private let itemsPerPage = 30
    
    init(githubRepositoryProvider: GitHubRepositoryProvider) {
        self.githubRepositoryProvider = githubRepositoryProvider
    }
    
    func searchRepositories(
        query: String,
        sortOption: RepositorySortOption,
        sortOrder: SortOrder,
        page: Int
    ) -> AnyPublisher<SearchRepositoriesResponse, Error> {
        
        let parameters = RepositorySearchParameters(
            query: query,
            sort: sortOption,
            order: sortOrder,
            perPage: itemsPerPage,
            page: page
        )
        
        return githubRepositoryProvider.searchRepositories(parameters: parameters)
    }
}

final class RepositorySearchCoordinator: ObservableObject {
    
    @Published var repositories: [RepositoryModel] = []
    @Published var totalCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreData: Bool = true
    @Published var error: Error?
    
    private let searchService: RepositorySearchServiceProtocol
    private let historyStorageProvider: HistoryStorageProvider
    private var cancellables: Set<AnyCancellable> = []
    private var currentPage = 1
    private var currentQuery = ""
    private var currentSortOption: RepositorySortOption = .bestMatch
    private var currentSortOrder: SortOrder = .desc
    
    init(
        searchService: RepositorySearchServiceProtocol,
        historyStorageProvider: HistoryStorageProvider
    ) {
        self.searchService = searchService
        self.historyStorageProvider = historyStorageProvider
    }
    
    func search(
        query: String,
        sortOption: RepositorySortOption = .bestMatch,
        sortOrder: SortOrder = .desc,
        resetResults: Bool = true
    ) {
        // If query is empty, just clear results
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }
        
        // Update current parameters
        currentQuery = query
        currentSortOption = sortOption
        currentSortOrder = sortOrder
        
        if resetResults {
            currentPage = 1
            hasMoreData = true
            repositories = []
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        error = nil
        
        searchService.searchRepositories(
            query: query,
            sortOption: sortOption,
            sortOrder: sortOrder,
            page: currentPage
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (completion: Subscribers.Completion<Error>) in
            self?.isLoading = false
            self?.isLoadingMore = false
            
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] (response: SearchRepositoriesResponse) in
            guard let self = self else { return }
            
            if resetResults {
                self.repositories = response.items
            } else {
                self.repositories.append(contentsOf: response.items)
            }
            
            self.totalCount = response.totalCount
            self.hasMoreData = response.items.count == 30 
            self.currentPage += 1
        }
        .store(in: &cancellables)
    }
    
    func loadMoreData() {
        guard hasMoreData && !isLoadingMore && !isLoading else { return }
        
        search(
            query: currentQuery,
            sortOption: currentSortOption,
            sortOrder: currentSortOrder,
            resetResults: false
        )
    }
    
    func selectRepository(_ repository: RepositoryModel) {
        historyStorageProvider.addRepositoryToHistory(repository)
    }
    
    private func clearResults() {
        repositories = []
        totalCount = 0
        currentPage = 1
        hasMoreData = true
        isLoading = false
        isLoadingMore = false
        error = nil
    }
}
