//
//  UserRepositoriesView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct UserRepositoriesView: View {
    @StateObject private var viewModel = UserRepositoriesViewModel()
    @State private var showingSafari = false
    @State private var safariURL: URL?
    @State private var username: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Enter username...", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            if !username.isEmpty {
                                viewModel.loadUserRepositories(username: username)
                            }
                        }
                    
                    Button("Load") {
                        if !username.isEmpty {
                            viewModel.loadUserRepositories(username: username)
                        }
                    }
                    .disabled(username.isEmpty)
                }
                .padding()
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading repositories...")
                    Spacer()
                } else if viewModel.repositories.isEmpty && !username.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "folder")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No repositories found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if !username.isEmpty {
                    List(viewModel.repositories) { repository in
                        RepositoryRowView(repository: repository) {
                            viewModel.selectRepository(repository)
                            safariURL = URL(string: repository.htmlUrl)
                            showingSafari = true
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Enter a username to view repositories")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle("User Repositories")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
            .errorAlert(isPresented: $viewModel.showError, error: viewModel.error)
        }
    }
}

#Preview {
    UserRepositoriesView()
}