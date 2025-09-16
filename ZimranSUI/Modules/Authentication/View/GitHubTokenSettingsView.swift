//
//  GitHubTokenSettingsView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import Combine

struct GitHubTokenSettingsView: View {
    @State private var token: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var hasToken: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let authCredentialsProvider = DependencyContainer.shared.resolve(AuthCredentialsProvider.self)!
    private let authProvider = DependencyContainer.shared.resolve(AuthProvider.self)!
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("GitHub Personal Access Token")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Add your GitHub token to increase API rate limits from 60 to 5000 requests per hour")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to get a token:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Go to GitHub Settings → Developer settings")
                        Text("2. Click 'Personal access tokens' → 'Tokens (classic)'")
                        Text("3. Click 'Generate new token'")
                        Text("4. Select 'public_repo' scope")
                        Text("5. Copy the generated token")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    SecureField("Enter your GitHub token", text: $token)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    HStack(spacing: 12) {
                        Button("Save Token") {
                            saveToken()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(token.isEmpty || isLoading)
                        
                        Button("Clear Token") {
                            clearToken()
                        }
                        .buttonStyle(.bordered)
                        .disabled(!hasToken || isLoading)
                    }
                    
                    if isLoading {
                        ProgressView("Validating token...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                if hasToken {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Token is configured")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Text("Rate limit: 5000 requests/hour")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("No token configured")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Rate limit: 60 requests/hour")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("GitHub Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                updateTokenState()
            }
            .onReceive(NotificationCenter.default.publisher(for: .tokenUpdated)) { _ in
                updateTokenState()
            }
            .alert("Token Settings", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveToken() {
        isLoading = true
        
        authProvider.authenticateWithToken(token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        alertMessage = "Failed to validate token: \(error.localizedDescription)"
                        showingAlert = true
                    }
                },
                receiveValue: { user in
                    alertMessage = "Token validated successfully! Welcome, \(user.login)"
                    showingAlert = true
                }
            )
            .store(in: &cancellables)
    }
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    private func clearToken() {
        authCredentialsProvider.clearToken()
        token = ""
        updateTokenState()
        alertMessage = "Token cleared successfully!"
        showingAlert = true
    }
    
    private func updateTokenState() {
        token = authCredentialsProvider.token ?? ""
        hasToken = authCredentialsProvider.token != nil
    }
}

extension Notification.Name {
    static let tokenUpdated = Notification.Name("tokenUpdated")
}

#Preview {
    GitHubTokenSettingsView()
}
