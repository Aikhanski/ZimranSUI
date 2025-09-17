//
//  SearchView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct SafariItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var safariItem: SafariItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed SearchBar at top - always visible
                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: "Search users...",
                    onSubmit: viewModel.search,
                    searchAction: viewModel.search
                )
                .background(Color.primaryBackground)
                .zIndex(1) // Ensure it stays on top

                // Content area with controls and results
                VStack(spacing: 0) {
                    // Sort controls - only show when there are results
                    if !viewModel.users.isEmpty {
                        UserSortControlsView(
                            sortOption: $viewModel.sortOption,
                            sortOrder: $viewModel.sortOrder,
                            onSortOptionChanged: viewModel.changeSortOption,
                            onSortOrderToggled: viewModel.toggleSortOrder
                        )
                        .background(Color.primaryBackground)
                        
                        ResultHeaderView(
                            totalCount: viewModel.totalCount,
                            isLoading: viewModel.isLoading
                        )
                        .background(Color.primaryBackground)
                    }

                    // Scrollable content
                    contentView
                }
            }
            .navigationTitle("Search Users")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url)
            }
            .errorAlert(isPresented: $viewModel.showError, error: viewModel.error)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            LoadingView(message: "Searching users...")
        } else if let error = viewModel.error {
            EmptyStateView(
                icon: "exclamationmark.triangle",
                title: "Error",
                subtitle: error.localizedDescription,
                actionTitle: "Try Again"
            ) {
                viewModel.search()
            }
        } else if viewModel.users.isEmpty && !viewModel.searchText.isEmpty {
            EmptyStateView(
                icon: "person.circle",
                title: "No users found",
                subtitle: "Try a different search term"
            )
        } else if !viewModel.users.isEmpty {
            List(viewModel.users) { user in
                UserRowView(user: user) {
                    viewModel.selectUser(user)
                    if let url = URL(string: user.htmlUrl) {
                        safariItem = SafariItem(url: url)
                    }
                }
                .onAppear {
                    if user == viewModel.users.last {
                        viewModel.loadMoreData()
                    }
                }
            }
            .listStyle(PlainListStyle())
        } else {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "Search GitHub Users",
                subtitle: "Enter a username to get started"
            )
        }
        
        if viewModel.isLoading && !viewModel.users.isEmpty {
            LoadingOverlay(message: "Loading more...")
        }
    }
}

#Preview {
    SearchView()
}
