//
//  GitHubTokenSettingsView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct GitHubTokenSettingsView: View {
    @State private var token: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
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
                        .disabled(token.isEmpty)
                        
                        Button("Clear Token") {
                            clearToken()
                        }
                        .buttonStyle(.bordered)
                        .disabled(GitHubTokenManager.shared.token == nil)
                    }
                }
                .padding(.horizontal)
                
                if GitHubTokenManager.shared.token != nil {
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
                token = GitHubTokenManager.shared.token ?? ""
            }
            .alert("Token Settings", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveToken() {
        GitHubTokenManager.shared.token = token
        alertMessage = "Token saved successfully!"
        showingAlert = true
    }
    
    private func clearToken() {
        GitHubTokenManager.shared.clearAllTokens()
        token = ""
        alertMessage = "Token cleared successfully!"
        showingAlert = true
    }
}

#Preview {
    GitHubTokenSettingsView()
}
