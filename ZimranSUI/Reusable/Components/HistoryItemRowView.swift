//
//  HistoryItemRowView.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct HistoryItemRowView: View {
    let item: HistoryItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .spacingM) {
                Image(systemName: item.type == .repository ? "folder.fill" : "person.circle.fill")
                    .foregroundColor(item.type == .repository ? .accentBlue : .accentGreen)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text(item.title)
                        .font(.labelLarge)
                        .foregroundColor(.primaryText)
                    
                    Text(item.subtitle)
                        .font(.captionRegular)
                        .foregroundColor(.secondaryText)
                    
                    Text(item.timestamp, style: .relative)
                        .font(.captionSmall)
                        .foregroundColor(.tertiaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondaryText)
                    .font(.caption)
            }
            .padding(.vertical, CGFloat.paddingXS)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    List {
        HistoryItemRowView(
            item: HistoryItem(
                id: "repo_1",
                title: "swift",
                subtitle: "Apple's Swift programming language",
                url: "https://github.com/apple/swift",
                timestamp: Date().addingTimeInterval(-3600),
                type: .repository
            )
        ) {
            print("Repository tapped")
        }
        
        HistoryItemRowView(
            item: HistoryItem(
                id: "user_1",
                title: "octocat",
                subtitle: "User",
                url: "https://github.com/octocat",
                timestamp: Date().addingTimeInterval(-7200),
                type: .user
            )
        ) {
            print("User tapped")
        }
    }
    .listStyle(PlainListStyle())
}
