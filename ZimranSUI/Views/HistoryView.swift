//
//  HistoryView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI
import SafariServices

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingSafari = false
    @State private var safariURL: URL?
    @State private var showingUserRepositories = false
    @State private var selectedUser: User?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("History Type", selection: $viewModel.selectedTab) {
                    ForEach(HistoryViewModel.HistoryTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedTab) { _, newValue in
                    viewModel.switchTab(newValue)
                }
                
                // Content
                if viewModel.selectedTab == .repositories {
                    if viewModel.repositoryHistory.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "clock")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No repository history")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Viewed repositories will appear here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.repositoryHistory) { item in
                                HistoryItemRowView(item: item) {
                                    safariURL = URL(string: item.url)
                                    showingSafari = true
                                }
                            }
                            .onDelete(perform: deleteRepositoryHistory)
                        }
                        .listStyle(PlainListStyle())
                    }
                } else {
                    if viewModel.userHistory.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No user history")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Viewed users will appear here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.userHistory) { item in
                                HistoryItemRowView(item: item) {
                                    // For users, we need to create a User object from the history item
                                    // This is a simplified approach - in a real app you might want to store more user data
                                    let user = User(
                                        id: Int(item.id.replacingOccurrences(of: "user_", with: "")) ?? 0,
                                        login: item.title,
                                        avatarURL: "",
                                        htmlURL: item.url,
                                        type: "User",
                                        siteAdmin: false,
                                        followers: nil,
                                        following: nil,
                                        publicRepos: nil,
                                        publicGists: nil,
                                        createdAt: nil,
                                        updatedAt: nil
                                    )
                                    selectedUser = user
                                    showingUserRepositories = true
                                }
                            }
                            .onDelete(perform: deleteUserHistory)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if viewModel.selectedTab == .repositories {
                            Button("Clear Repository History", role: .destructive) {
                                viewModel.clearRepositoryHistory()
                            }
                        } else {
                            Button("Clear User History", role: .destructive) {
                                viewModel.clearUserHistory()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $showingUserRepositories) {
                if let user = selectedUser {
                    NavigationView {
                        UserRepositoriesView(user: user)
                    }
                }
            }
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }
    
    private func deleteRepositoryHistory(offsets: IndexSet) {
        // In a real app, you might want to implement individual item deletion
        viewModel.clearRepositoryHistory()
    }
    
    private func deleteUserHistory(offsets: IndexSet) {
        // In a real app, you might want to implement individual item deletion
        viewModel.clearUserHistory()
    }
}

struct HistoryItemRowView: View {
    let item: HistoryItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: item.type == .repository ? "folder.fill" : "person.circle.fill")
                    .foregroundColor(item.type == .repository ? .blue : .green)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(item.timestamp, style: .relative)
                        .font(.caption2)
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
    HistoryView()
}
