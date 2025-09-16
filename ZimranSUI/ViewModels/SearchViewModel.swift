//
//  SearchViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var repositories: [Repository] = []
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTab: SearchTab = .repositories
    @Published var repositorySortType: RepositorySortType = .stars
    @Published var userSortType: UserSortType = .followers
    @Published var currentPage: Int = 1
    @Published var hasMoreData: Bool = true
    
    private let networkProvider: NetworkProvider
    private let historyStorage: HistoryStorage
    private var cancellables = Set<AnyCancellable>()
    private let itemsPerPage = 30
    
    enum SearchTab: String, CaseIterable {
        case repositories = "Repositories"
        case users = "Users"
    }
    
    init(networkProvider: NetworkProvider = NetworkProvider.shared,
         historyStorage: HistoryStorage = HistoryStorage.shared) {
        self.networkProvider = networkProvider
        self.historyStorage = historyStorage
    }
    
    func search() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }
        
        currentPage = 1
        hasMoreData = true
        
        switch selectedTab {
        case .repositories:
            searchRepositories()
        case .users:
            searchUsers()
        }
    }
    
    func loadMoreData() {
        guard hasMoreData && !isLoading else { return }
        
        currentPage += 1
        
        switch selectedTab {
        case .repositories:
            searchRepositories(append: true)
        case .users:
            searchUsers(append: true)
        }
    }
    
    func switchTab(_ tab: SearchTab) {
        selectedTab = tab
        clearResults()
        if !searchText.isEmpty {
            search()
        }
    }
    
    func changeRepositorySortType(_ sortType: RepositorySortType) {
        repositorySortType = sortType
        if !repositories.isEmpty {
            search()
        }
    }
    
    func changeUserSortType(_ sortType: UserSortType) {
        userSortType = sortType
        if !users.isEmpty {
            search()
        }
    }
    
    func selectRepository(_ repository: Repository) {
        historyStorage.addRepositoryToHistory(repository)
    }
    
    func selectUser(_ user: User) {
        historyStorage.addUserToHistory(user)
    }
    
    private func searchRepositories(append: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let target = GitHubAPI.searchRepositories(
            query: searchText,
            sort: repositorySortType.rawValue,
            order: "desc",
            page: currentPage,
            perPage: itemsPerPage
        )
        
        networkProvider.request(target, responseType: RepositorySearchResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.getErrorMessage(for: error)
                    }
                },
                receiveValue: { [weak self] response in
                    if append {
                        self?.repositories.append(contentsOf: response.items)
                    } else {
                        self?.repositories = response.items
                    }
                    self?.hasMoreData = response.items.count == self?.itemsPerPage
                }
            )
            .store(in: &cancellables)
    }
    
    private func searchUsers(append: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let target = GitHubAPI.searchUsers(
            query: searchText,
            sort: userSortType.rawValue,
            order: "desc",
            page: currentPage,
            perPage: itemsPerPage
        )
        
        networkProvider.request(target, responseType: UserSearchResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.getErrorMessage(for: error)
                    }
                },
                receiveValue: { [weak self] response in
                    if append {
                        self?.users.append(contentsOf: response.items)
                    } else {
                        self?.users = response.items
                    }
                    self?.hasMoreData = response.items.count == self?.itemsPerPage
                }
            )
            .store(in: &cancellables)
    }
    
    private func clearResults() {
        repositories = []
        users = []
        currentPage = 1
        hasMoreData = true
        errorMessage = nil
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
