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
    @State private var safariItem: SafariItem?
    @State private var showingUserRepositories = false
    @State private var selectedUser: UserModel?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                tabPicker
                contentView
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearMenu
                }
            }
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url)
            }
            .sheet(isPresented: $showingUserRepositories) {
                NavigationView {
                    UserRepositoriesView()
                }
            }
            .onAppear {
                viewModel.loadHistory()
            }
            .onReceive(NotificationCenter.default.publisher(for: .historyUpdated)) { _ in
                viewModel.loadHistory()
            }
            .refreshable {
                await viewModel.refreshHistory()
            }
        }
    }
    
    private var tabPicker: some View {
        Picker("History Type", selection: $viewModel.selectedTab) {
            ForEach(HistoryViewModel.HistoryTab.allCases, id: \.self) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .onChange(of: viewModel.selectedTab) { _, newValue in
            viewModel.switchTab(newValue)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.selectedTab == .repositories {
            repositoryContent
        } else {
            userContent
        }
    }
    
    @ViewBuilder
    private var repositoryContent: some View {
        if viewModel.repositoryHistory.isEmpty {
            emptyRepositoryState
        } else {
            repositoryList
        }
    }
    
    @ViewBuilder
    private var userContent: some View {
        if viewModel.userHistory.isEmpty {
            emptyUserState
        } else {
            userList
        }
    }
    
    private var emptyRepositoryState: some View {
        VStack {
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
        }
    }
    
    private var emptyUserState: some View {
        VStack {
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
        }
    }
    
    private var repositoryList: some View {
        List {
            ForEach(viewModel.repositoryHistory) { item in
                HistoryItemRowView(item: item) {
                    if let url = URL(string: item.url) {
                        safariItem = SafariItem(url: url)
                    }
                }
            }
            .onDelete(perform: deleteRepositoryHistory)
        }
        .listStyle(PlainListStyle())
    }
    
    private var userList: some View {
        List {
            ForEach(viewModel.userHistory) { item in
                HistoryItemRowView(item: item) {
                    let user = UserModel(
                        id: Int(item.id.replacingOccurrences(of: "user_", with: "")) ?? 0,
                        login: item.title,
                        avatarUrl: "",
                        htmlUrl: item.url,
                        type: "User",
                        siteAdmin: false
                    )
                    selectedUser = user
                    showingUserRepositories = true
                }
            }
            .onDelete(perform: deleteUserHistory)
        }
        .listStyle(PlainListStyle())
    }
    
    private var clearMenu: some View {
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
    
    private func deleteRepositoryHistory(offsets: IndexSet) {
        let historyStorageProvider = DependencyContainer.shared.resolve(HistoryStorageProvider.self)!
        offsets.map { viewModel.repositoryHistory[$0] }.forEach { item in
            historyStorageProvider.deleteRepositoryHistoryItem(item.id)
        }
        viewModel.loadHistory()
    }
    
    private func deleteUserHistory(offsets: IndexSet) {
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
