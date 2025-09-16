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
                searchBar
                sortControls
                content
            }
            .navigationTitle("Search Users")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url)
            }
            .errorAlert(isPresented: $viewModel.showError, error: viewModel.error)
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search users...", text: $viewModel.searchText)
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
        if !viewModel.users.isEmpty {
            HStack {
                Text("Sort by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(UserSortOption.allCases, id: \.self) { sortType in
                        Text(sortType.rawValue).tag(sortType)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            Spacer()
            ProgressView("Searching...")
            Spacer()
        } else if viewModel.users.isEmpty && !viewModel.searchText.isEmpty {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("No users found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Try a different search term")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        } else if !viewModel.searchText.isEmpty {
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
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Search GitHub Users")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Enter a username to get started")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        
        if viewModel.isLoading && !viewModel.users.isEmpty {
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Spacer()
            }
            .padding()
        }
    }
}

struct UserRowView: View {
    let user: UserModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.login)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(user.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchView()
}
