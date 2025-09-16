//
//  UserRepositoriesView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct UserRepositoriesView: View {
    let user: User
    @StateObject private var viewModel: UserRepositoriesViewModel
    @State private var showingSafari = false
    @State private var safariURL: URL?
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: UserRepositoriesViewModel(username: user.login))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // User Info Header
            VStack(spacing: 12) {
                AsyncImage(url: URL(string: user.avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                Text(user.login)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    if let followers = user.followers {
                        VStack {
                            Text("\(followers)")
                                .font(.headline)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let following = user.following {
                        VStack {
                            Text("\(following)")
                                .font(.headline)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let publicRepos = user.publicRepos {
                        VStack {
                            Text("\(publicRepos)")
                                .font(.headline)
                            Text("Repos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Sort Controls
            HStack {
                Text("Sort by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $viewModel.sortType) {
                    ForEach(RepositorySortType.allCases, id: \.self) { sortType in
                        Text(sortType.displayName).tag(sortType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Repositories List
            if viewModel.isLoading && viewModel.repositories.isEmpty {
                Spacer()
                ProgressView("Loading repositories...")
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
            } else if viewModel.repositories.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "folder")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No repositories found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
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
        .navigationTitle("Repositories")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadRepositories()
        }
        .sheet(isPresented: $showingSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
    }
}

#Preview {
    NavigationView {
        UserRepositoriesView(user: User(
            id: 1,
            login: "octocat",
            avatarURL: "https://github.com/images/error/octocat_happy.gif",
            htmlURL: "https://github.com/octocat",
            type: "User",
            siteAdmin: false,
            followers: 1000,
            following: 100,
            publicRepos: 50,
            publicGists: 10,
            createdAt: "2008-01-14T04:33:35Z",
            updatedAt: "2023-01-14T04:33:35Z"
        ))
    }
}
