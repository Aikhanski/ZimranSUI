//
//  RepositorySearchView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct RepositorySearchView: View {
    @StateObject private var viewModel = RepositorySearchViewModel()
    @State private var safariItem: SafariItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed SearchBar at top - always visible
                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: "Search repositories...",
                    onSubmit: viewModel.search,
                    searchAction: viewModel.search
                )
                .background(Color.primaryBackground)
                .zIndex(1) // Ensure it stays on top

                // Content area with controls and results
                VStack(spacing: 0) {
                    // Sort controls - only show when there are results
                    if !viewModel.repositories.isEmpty {
                        SortControlsView(
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
            .navigationTitle("Repository Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url)
            }
            .errorAlert(isPresented: $viewModel.showError, error: viewModel.error)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.repositories.isEmpty {
            LoadingView(message: "Searching repositories...")
        } else if let error = viewModel.error {
            EmptyStateView(
                icon: "exclamationmark.triangle",
                title: "Error",
                subtitle: error.localizedDescription,
                actionTitle: "Try Again"
            ) {
                viewModel.search()
            }
        } else if viewModel.repositories.isEmpty && !viewModel.searchText.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No repositories found",
                subtitle: "Try a different search term"
            )
        } else if !viewModel.repositories.isEmpty {
            RepositoryListView(
                repositories: viewModel.repositories,
                isLoadingMore: viewModel.isLoading && !viewModel.repositories.isEmpty,
                onRepositoryTap: { repository in
                    viewModel.selectRepository(repository)
                    if let url = URL(string: repository.htmlUrl) {
                        safariItem = SafariItem(url: url)
                    }
                },
                onLoadMore: viewModel.loadMoreData
            )
        } else {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "Search GitHub Repositories",
                subtitle: "Enter a search term to get started"
            )
        }
    }
}

struct RepositoryModelRowView: View {
    let repository: RepositoryModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: .spacingM) {
                HStack {
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Text(repository.name)
                            .font(.labelLarge)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        
                        Text(repository.fullName)
                            .font(.captionLarge)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: .spacingXS) {
                        HStack(spacing: .spacingM) {
                            Label("\(repository.stargazersCount)", systemImage: "star.fill")
                                .font(.captionRegular)
                                .foregroundColor(.accentOrange)
                            
                            Label("\(repository.forksCount)", systemImage: "arrow.triangle.branch")
                                .font(.captionRegular)
                                .foregroundColor(.accentBlue)
                        }
                        
                        if let language = repository.language {
                            Text(language)
                                .font(.captionSmall)
                                .padding(.horizontal, CGFloat.paddingS)
                                .padding(.vertical, CGFloat.paddingXS)
                                .background(Color.accentBlue.opacity(0.1))
                                .foregroundColor(.accentBlue)
                                .cornerRadius(.radiusS)
                        }
                    }
                }
                
                if let description = repository.description {
                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                }
                
                HStack {
                    HStack(spacing: .spacingXS) {
                        AsyncImage(url: URL(string: repository.owner.avatarUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.secondaryBackground)
                        }
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                        
                        Text(repository.owner.login)
                            .font(.captionRegular)
                            .foregroundColor(.accentBlue)
                    }
                    
                    Spacer()
                    
                    Text("Updated \(repository.updatedAt, style: .relative)")
                        .font(.captionSmall)
                        .foregroundColor(.tertiaryText)
                }
            }
            .padding(CGFloat.paddingM)
            .background(Color.primaryBackground)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.borderSecondary),
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    RepositorySearchView()
}
