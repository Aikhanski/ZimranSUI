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
    @State private var safariItem: SafariItem?
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
                            if let url = URL(string: repository.htmlUrl) {
                                safariItem = SafariItem(url: url)
                            }
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
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url)
            }
            .errorAlert(isPresented: $viewModel.showError, error: viewModel.error)
        }
    }
}

#Preview {
    UserRepositoriesView()
}
