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
                        .font(.labelLarge)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: .spacingM) {
                        HStack(spacing: .spacingXS) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.accentOrange)
                                .font(.caption)
                            Text("\(repository.stargazersCount)")
                                .font(.captionRegular)
                                .foregroundColor(.secondaryText)
                        }
                        
                        HStack(spacing: .spacingXS) {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundColor(.accentBlue)
                                .font(.caption)
                            Text("\(repository.forksCount)")
                                .font(.captionRegular)
                                .foregroundColor(.secondaryText)
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
                    if let language = repository.language {
                        Text(language)
                            .font(.captionSmall)
                            .padding(.horizontal, CGFloat.paddingS)
                            .padding(.vertical, CGFloat.paddingXS)
                            .background(Color.accentBlue.opacity(0.1))
                            .foregroundColor(.accentBlue)
                            .cornerRadius(.radiusS)
                    }
                    
                    Spacer()
                    
                    Text("Updated \(formatDate(repository.updatedAt))")
                        .font(.captionRegular)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(CGFloat.paddingL)
            .background(Color.primaryBackground)
            .cornerRadius(.radiusM)
            .shadow(color: .shadowLight, radius: 1, x: 0, y: 1)
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
