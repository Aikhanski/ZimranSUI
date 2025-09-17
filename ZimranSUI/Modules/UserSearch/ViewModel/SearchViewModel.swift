//
//  SearchViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var users: [UserModel] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var sortOption: UserSortOption = .bestMatch
    @Published var sortOrder: SortOrder = .desc
    @Published var currentPage: Int = 1
    @Published var hasMoreData: Bool = true
    @Published var totalCount: Int = 0
    
    var error: Error?
    
    private let githubUserProvider = DependencyContainer.shared.resolve(GitHubUserProvider.self)!
    private let historyStorageProvider = DependencyContainer.shared.resolve(HistoryStorageProvider.self)!
    private let router = DependencyContainer.shared.resolve(Router.self)!
    private var cancellables: Set<AnyCancellable> = []
    private let itemsPerPage = 30
    
    init() {
        setupDebouncedSearch()
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
    
    func changeSortOption(_ sortOption: UserSortOption) {
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
    
    func selectUser(_ user: UserModel) {
        historyStorageProvider.addUserToHistory(user)
    }
    
    private func performSearch(append: Bool = false) {
        isLoading = true
        showError = false
        
        githubUserProvider.searchUsers(query: searchText, sort: sortOption, order: sortOrder)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.showError = true
                }
            } receiveValue: { [weak self] response in
                if append {
                    self?.users.append(contentsOf: response.items)
                } else {
                    self?.users = response.items
                }
                self?.totalCount = response.totalCount
                self?.hasMoreData = response.items.count == self?.itemsPerPage
            }
            .store(in: &cancellables)
    }
    
    private func clearResults() {
        users = []
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
