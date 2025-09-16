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
    @State private var showingSafari = false
    @State private var safariURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Search repositories...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.search()
                        }
                    
                    Button("Search") {
                        viewModel.search()
                    }
                    .disabled(viewModel.searchText.isEmpty)
                }
                .padding()
                
                // Sort Controls
                if !viewModel.repositories.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Sort by:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("Sort", selection: $viewModel.sortOption) {
                                ForEach(RepositorySortOption.allCases, id: \.self) { sortOption in
                                    Text(sortOption.displayName).tag(sortOption)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: viewModel.sortOption) { _, newValue in
                                viewModel.changeSortOption(newValue)
                            }
                        }
                        
                        if viewModel.sortOption != .bestMatch {
                            HStack {
                                Text("Order:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Order", selection: $viewModel.sortOrder) {
                                    ForEach(SortOrder.allCases, id: \.self) { order in
                                        Text(order.displayName).tag(order)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: viewModel.sortOrder) { _, newValue in
                                    viewModel.changeSortOrder(newValue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Results Info
                if !viewModel.repositories.isEmpty {
                    HStack {
                        Text("\(viewModel.totalCount) repositories found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Content
                if viewModel.isLoading && viewModel.repositories.isEmpty {
                    Spacer()
                    ProgressView("Searching repositories...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            viewModel.search()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else if viewModel.repositories.isEmpty && !viewModel.searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No repositories found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.repositories) { repository in
                                RepositoryModelRowView(repository: repository) {
                                    viewModel.selectRepository(repository)
                                    safariURL = URL(string: repository.htmlUrl)
                                    showingSafari = true
                                }
                                .onAppear {
                                    if repository == viewModel.repositories.last {
                                        viewModel.loadMoreData()
                                    }
                                }
                            }
                            
                            if viewModel.isLoading && !viewModel.repositories.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Repository Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
        }
    }
}

struct RepositoryModelRowView: View {
    let repository: RepositoryModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with name and stats
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repository.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(repository.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 12) {
                            Label("\(repository.stargazersCount)", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Label("\(repository.forksCount)", systemImage: "arrow.triangle.branch")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if let language = repository.language {
                            Text(language)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Description
                if let description = repository.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Footer with owner and update date
                HStack {
                    HStack(spacing: 6) {
                        AsyncImage(url: URL(string: repository.owner.avatarUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                        
                        Text(repository.owner.login)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Updated \(repository.updatedAt, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    RepositorySearchView()
}
