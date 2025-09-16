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
    
    private let githubRepositoryProvider = DependencyContainer.shared.resolve(GitHubRepositoryProvider.self)!
    private let router = DependencyContainer.shared.resolve(Router.self)!
    private var cancellables: Set<AnyCancellable> = []
    
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
        let historyStorageProvider = DependencyContainer.shared.resolve(HistoryStorageProvider.self)!
        historyStorageProvider.addRepositoryToHistory(repository)
    }
}
