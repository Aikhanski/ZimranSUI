//
//  SearchView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showingSafari = false
    @State private var safariURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                sortControls
                tabSelection
                contentView
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search \(viewModel.selectedTab.rawValue.lowercased())...", text: $viewModel.searchText)
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
    }
    
    @ViewBuilder
    private var sortControls: some View {
        if !viewModel.repositories.isEmpty || !viewModel.users.isEmpty {
            HStack {
                Text("Sort by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                sortPicker
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var sortPicker: some View {
        if viewModel.selectedTab == .repositories {
            Picker("Sort", selection: Binding(
                get: { viewModel.repositorySortType },
                set: { viewModel.changeRepositorySortType($0) }
            )) {
                ForEach(RepositorySortType.allCases, id: \.self) { sortType in
                    Text(sortType.displayName).tag(sortType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        } else {
            Picker("Sort", selection: Binding(
                get: { viewModel.userSortType },
                set: { viewModel.changeUserSortType($0) }
            )) {
                ForEach(UserSortType.allCases, id: \.self) { sortType in
                    Text(sortType.displayName).tag(sortType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var tabSelection: some View {
        Picker("Search Type", selection: $viewModel.selectedTab) {
            ForEach(SearchViewModel.SearchTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onChange(of: viewModel.selectedTab) { _, newValue in
            viewModel.switchTab(newValue)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.repositories.isEmpty && viewModel.users.isEmpty {
            Spacer()
            ProgressView("Searching...")
            Spacer()
        } else if let errorMessage = viewModel.errorMessage {
            errorView(errorMessage)
        } else {
            resultsView
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
        }
    }
    
    private var resultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.selectedTab == .repositories {
                    repositoryResults
                } else {
                    userResults
                }
                
                loadingIndicator
            }
            .padding(.horizontal)
        }
    }
    
    private var repositoryResults: some View {
        ForEach(viewModel.repositories) { repository in
            RepositoryRowView(repository: repository) {
                viewModel.selectRepository(repository)
                safariURL = URL(string: repository.htmlURL)
                showingSafari = true
            }
            .onAppear {
                if repository == viewModel.repositories.last {
                    viewModel.loadMoreData()
                }
            }
        }
    }
    
    private var userResults: some View {
        ForEach(viewModel.users) { user in
            UserRowView(user: user) {
                viewModel.selectUser(user)
            }
            .onAppear {
                if user == viewModel.users.last {
                    viewModel.loadMoreData()
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isLoading && (!viewModel.repositories.isEmpty || !viewModel.users.isEmpty) {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding()
        }
    }
}

struct RepositoryRowView: View {
    let repository: Repository
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(repository.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Label("\(repository.stargazersCount)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(repository.forksCount)", systemImage: "arrow.triangle.branch")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let description = repository.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(repository.owner.login)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
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

struct UserRowView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: user.avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.login)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        if let followers = user.followers {
                            Label("\(followers)", systemImage: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let publicRepos = user.publicRepos {
                            Label("\(publicRepos)", systemImage: "folder.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
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
    SearchView()
}
