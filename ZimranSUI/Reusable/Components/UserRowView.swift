//
//  UserRowView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct UserRowView: View {
    let user: UserModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .spacingM) {
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.secondaryText)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    Text(user.login)
                        .font(.labelLarge)
                        .foregroundColor(.primaryText)
                    
                    Text(user.type)
                        .font(.captionRegular)
                        .foregroundColor(.secondaryText)
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
        UserRowView(
            user: UserModel(
                id: 1,
                login: "octocat",
                avatarUrl: "https://github.com/images/error/octocat_happy.gif",
                htmlUrl: "https://github.com/octocat",
                type: "User",
                siteAdmin: false
            )
        ) {
            print("User tapped")
        }
        
        UserRowView(
            user: UserModel(
                id: 2,
                login: "defunkt",
                avatarUrl: "https://github.com/images/error/octocat_happy.gif",
                htmlUrl: "https://github.com/defunkt",
                type: "User",
                siteAdmin: true
            )
        ) {
            print("User tapped")
        }
    }
    .listStyle(PlainListStyle())
}
