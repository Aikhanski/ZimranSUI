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
                SearchBar(
                    text: $username,
                    placeholder: "Enter username...",
                    onSubmit: {
                        if !username.isEmpty {
                            viewModel.loadUserRepositories(username: username)
                        }
                    },
                    searchAction: {
                        if !username.isEmpty {
                            viewModel.loadUserRepositories(username: username)
                        }
                    }
                )

                if viewModel.isLoading {
                    LoadingView(message: "Loading repositories...")
                } else if viewModel.repositories.isEmpty && !username.isEmpty {
                    EmptyStateView(
                        icon: "folder",
                        title: "No repositories found"
                    )
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
                    EmptyStateView(
                        icon: "person.circle",
                        title: "Enter a username to view repositories"
                    )
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
