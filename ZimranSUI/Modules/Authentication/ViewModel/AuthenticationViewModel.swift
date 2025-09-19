//
//  AuthenticationViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

final class AuthenticationViewModel: ObservableObject {
    @Published var token: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var isAuthenticated: Bool = false
    
    var error: Error?
    
    private let authProvider: AuthProvider
    private let router: any RouterProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authProvider: AuthProvider,
        router: any RouterProtocol
    ) {
        self.authProvider = authProvider
        self.router = router
        self.isAuthenticated = authProvider.isAuthenticated
    }
    
    // MARK: - Convenience initializer for production
    convenience init() {
        self.init(
            authProvider: DependencyContainer.shared.resolve(AuthProvider.self)!,
            router: DependencyContainer.shared.resolve((any RouterProtocol).self)!
        )
    }
    
    func authenticateWithToken() {
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = AuthError.noToken
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        authProvider.authenticateWithToken(token)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.showError = true
                }
            } receiveValue: { [weak self] _ in
                self?.isAuthenticated = true
                self?.router.popToRoot()
            }
            .store(in: &cancellables)
    }
    
    func authenticateWithOAuth() {
        isLoading = true
        showError = false
        
        authProvider.authenticateWithOAuth()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    self?.showError = true
                }
            } receiveValue: { [weak self] _ in
                self?.isAuthenticated = true
                self?.router.popToRoot()
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        authProvider.signOut()
        isAuthenticated = false
        token = ""
        router.showAuthentication()
    }
}
