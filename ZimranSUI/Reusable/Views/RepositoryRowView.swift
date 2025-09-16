//
//  RepositoryRowView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct RepositoryRowView: View {
    let repository: RepositoryModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(repository.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("\(repository.stargazersCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(repository.forksCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let description = repository.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Text("Updated \(formatDate(repository.updatedAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    RepositoryRowView(
        repository: RepositoryModel(
            id: 1,
            name: "example-repo",
            fullName: "user/example-repo",
            htmlUrl: "https://github.com/user/example-repo",
            description: "This is an example repository",
            stargazersCount: 100,
            forksCount: 20,
            updatedAt: Date(),
            createdAt: Date(),
            language: "Swift",
            owner: OwnerModel(
                login: "user",
                avatarUrl: "https://github.com/images/error/octocat_happy.gif",
                htmlUrl: "https://github.com/user"
            )
        ),
        onTap: {}
    )
    .padding()
}
