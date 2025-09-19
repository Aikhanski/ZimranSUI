//
//  UserRepositoriesViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

final class UserRepositoriesViewModel: ObservableObject {
    @Published var repositories: [RepositoryModel] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var username: String = ""
    
    var error: Error?
    
    private let githubRepositoryProvider: GitHubRepositoryProvider
    private let historyStorageProvider: HistoryStorageProvider
    private let router: any RouterProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        githubRepositoryProvider: GitHubRepositoryProvider,
        historyStorageProvider: HistoryStorageProvider,
        router: any RouterProtocol
    ) {
        self.githubRepositoryProvider = githubRepositoryProvider
        self.historyStorageProvider = historyStorageProvider
        self.router = router
    }
    
    convenience init() {
        self.init(
            githubRepositoryProvider: DependencyContainer.shared.resolve(GitHubRepositoryProvider.self)!,
            historyStorageProvider: DependencyContainer.shared.resolve(HistoryStorageProvider.self)!,
            router: DependencyContainer.shared.resolve((any RouterProtocol).self)!
        )
    }
    
    func loadUserRepositories(username: String) {
        self.username = username
        isLoading = true
        showError = false
        
        githubRepositoryProvider.getUserRepositories(username: username)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.showError = true
                }
            } receiveValue: { [weak self] repositories in
                self?.repositories = repositories
            }
            .store(in: &cancellables)
    }
    
    func selectRepository(_ repository: RepositoryModel) {
        historyStorageProvider.addRepositoryToHistory(repository)
    }
}
