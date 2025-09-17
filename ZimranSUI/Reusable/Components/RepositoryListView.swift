//
//  RepositoryListView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct RepositoryListView: View {
    let repositories: [RepositoryModel]
    let isLoadingMore: Bool
    let onRepositoryTap: (RepositoryModel) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .spacingXS) {
                ForEach(repositories) { repository in
                    RepositoryModelRowView(repository: repository) {
                        onRepositoryTap(repository)
                    }
                    .onAppear {
                        if repository == repositories.last {
                            onLoadMore()
                        }
                    }
                }
                
                if isLoadingMore {
                    LoadingOverlay(message: "Loading more...")
                        .padding(.vertical, CGFloat.paddingM)
                }
            }
            .padding(.horizontal, CGFloat.paddingL)
        }
    }
}

#Preview {
    RepositoryListView(
        repositories: [
            RepositoryModel(
                id: 1,
                name: "swift",
                fullName: "apple/swift",
                htmlUrl: "https://github.com/apple/swift",
                description: "The Swift Programming Language",
                stargazersCount: 50000,
                forksCount: 8000,
                updatedAt: Date(),
                createdAt: Date(),
                language: "Swift",
                owner: OwnerModel(
                    login: "apple",
                    avatarUrl: "https://github.com/images/error/octocat_happy.gif",
                    htmlUrl: "https://github.com/apple"
                )
            )
        ],
        isLoadingMore: false,
        onRepositoryTap: { _ in },
        onLoadMore: { }
    )
}
