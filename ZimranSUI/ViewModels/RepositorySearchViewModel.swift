//
//  RepositorySearchViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

class RepositorySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var repositories: [RepositoryModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortOption: RepositorySortOption = .bestMatch
    @Published var sortOrder: SortOrder = .desc
    @Published var currentPage: Int = 1
    @Published var hasMoreData: Bool = true
    @Published var totalCount: Int = 0
    
    private let searchService: GitHubRepositorySearchService
    private let historyStorage: HistoryStorage
    private var cancellables = Set<AnyCancellable>()
    private let itemsPerPage = 30
    
    init(
        searchService: GitHubRepositorySearchService = GitHubRepositorySearchServiceImpl(),
        historyStorage: HistoryStorage = HistoryStorage.shared
    ) {
        self.searchService = searchService
        self.historyStorage = historyStorage
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
        if !repositories.isEmpty {
            search()
        }
    }
    
    func changeSortOrder(_ sortOrder: SortOrder) {
        self.sortOrder = sortOrder
        if !repositories.isEmpty {
            search()
        }
    }
    
    func selectRepository(_ repository: RepositoryModel) {
        // Convert RepositoryModel to Repository for history storage
        let repositoryForHistory = Repository(
            id: repository.id,
            name: repository.name,
            fullName: repository.fullName,
            description: repository.description,
            htmlURL: repository.htmlUrl,
            cloneURL: nil,
            language: repository.language,
            stargazersCount: repository.stargazersCount,
            forksCount: repository.forksCount,
            updatedAt: ISO8601DateFormatter().string(from: repository.updatedAt),
            createdAt: repository.createdAt.map { ISO8601DateFormatter().string(from: $0) } ?? "",
            owner: RepositoryOwner(
                id: 0, // OwnerModel doesn't have id, using 0 as default
                login: repository.owner.login,
                avatarURL: repository.owner.avatarUrl,
                htmlURL: repository.owner.htmlUrl
            )
        )
        historyStorage.addRepositoryToHistory(repositoryForHistory)
    }
    
    private func performSearch(append: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let parameters = RepositorySearchParameters(
            query: searchText,
            sort: sortOption,
            order: sortOrder,
            perPage: itemsPerPage,
            page: currentPage
        )
        
        searchService.searchRepositories(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    if append {
                        self?.repositories.append(contentsOf: response.items)
                    } else {
                        self?.repositories = response.items
                    }
                    self?.totalCount = response.totalCount
                    self?.hasMoreData = response.items.count == self?.itemsPerPage
                }
            )
            .store(in: &cancellables)
    }
    
    private func clearResults() {
        repositories = []
        currentPage = 1
        hasMoreData = true
        totalCount = 0
        errorMessage = nil
    }
}
