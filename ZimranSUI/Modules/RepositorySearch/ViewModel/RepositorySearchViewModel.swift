//
//  RepositorySearchViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

final class RepositorySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var repositories: [RepositoryModel] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var sortOption: RepositorySortOption = .bestMatch
    @Published var sortOrder: SortOrder = .desc
    @Published var currentPage: Int = 1
    @Published var hasMoreData: Bool = true
    @Published var totalCount: Int = 0
    
    var error: Error?
    
    private let githubRepositoryProvider: GitHubRepositoryProvider
    private let historyStorageProvider: HistoryStorageProvider
    private let router: any RouterProtocol
    private var cancellables: Set<AnyCancellable> = []
    private let itemsPerPage = 30
    
    init(
        githubRepositoryProvider: GitHubRepositoryProvider,
        historyStorageProvider: HistoryStorageProvider,
        router: any RouterProtocol
    ) {
        self.githubRepositoryProvider = githubRepositoryProvider
        self.historyStorageProvider = historyStorageProvider
        self.router = router
        setupDebouncedSearch()
    }
    
    convenience init() {
        self.init(
            githubRepositoryProvider: DependencyContainer.shared.resolve(GitHubRepositoryProvider.self)!,
            historyStorageProvider: DependencyContainer.shared.resolve(HistoryStorageProvider.self)!,
            router: DependencyContainer.shared.resolve((any RouterProtocol).self)!
        )
    }
    
    func search() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }
        
        currentPage = 1
        hasMoreData = true
        performSearch()
    }
    
    func loadMoreData() {
        guard hasMoreData && !isLoading else { return }
        
        currentPage += 1
        performSearch(append: true)
    }
    
    func changeSortOption(_ sortOption: RepositorySortOption) {
        self.sortOption = sortOption
        // Trigger search when sort option changes
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            search()
        }
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .asc ? .desc : .asc
        // Trigger search when sort order changes
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            search()
        }
    }
    
    func selectRepository(_ repository: RepositoryModel) {
        historyStorageProvider.addRepositoryToHistory(repository)
    }
    
    private func performSearch(append: Bool = false) {
        isLoading = true
        showError = false
        
        let parameters = RepositorySearchParameters(
            query: searchText,
            sort: sortOption,
            order: sortOrder,
            perPage: itemsPerPage,
            page: currentPage
        )
        
        githubRepositoryProvider.searchRepositories(parameters: parameters)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.showError = true
                }
            } receiveValue: { [weak self] response in
                if append {
                    self?.repositories.append(contentsOf: response.items)
                } else {
                    self?.repositories = response.items
                }
                self?.totalCount = response.totalCount
                self?.hasMoreData = response.items.count == self?.itemsPerPage
            }
            .store(in: &cancellables)
    }
    
    private func clearResults() {
        repositories = []
        currentPage = 1
        hasMoreData = true
        totalCount = 0
        showError = false
    }
    
    private func setupDebouncedSearch() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.clearResults()
                } else {
                    self.currentPage = 1
                    self.hasMoreData = true
                    self.performSearch()
                }
            }
            .store(in: &cancellables)
    }
}
