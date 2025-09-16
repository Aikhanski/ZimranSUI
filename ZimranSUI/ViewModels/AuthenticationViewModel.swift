//
//  AuthenticationViewModel.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkProvider: NetworkProvider
    private var cancellables = Set<AnyCancellable>()
    
    init(networkProvider: NetworkProvider = NetworkProvider.shared) {
        self.networkProvider = networkProvider
    }
    
    func authenticate() {
        guard !password.isEmpty else {
            errorMessage = "Please enter your Personal Access Token"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Используем Basic Authentication с Personal Access Token
        // username остается пустым, password - это токен
        let target = GitHubAPI.authenticate(username: "", password: password)
        
        networkProvider.request(target, responseType: AuthenticatedUser.self)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.getErrorMessage(for: error)
                    }
                },
                receiveValue: { [weak self] value in
                    print("ReceiveValue ", value)
                    self?.isAuthenticated = true
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        username = ""
        password = ""
        isAuthenticated = false
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
            if code == 401 {
                return "Invalid username or password"
            }
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
