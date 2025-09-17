//
//  EmptyStateView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: .spacingXL) {
            Spacer()
            
            VStack(spacing: .spacingL) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.secondaryText)
                
                VStack(spacing: .spacingS) {
                    Text(title)
                        .font(.titleMedium)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.bodyRegular)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if let actionTitle = actionTitle, let action = action {
                    SecondaryButton(title: actionTitle) {
                        action()
                    }
                    .padding(.horizontal, CGFloat.paddingXXL)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: .spacingXXL) {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            subtitle: "Try adjusting your search terms"
        )
        
        EmptyStateView(
            icon: "person.circle",
            title: "No users found",
            subtitle: "Try a different search term",
            actionTitle: "Try Again"
        ) {
            print("Try again tapped")
        }
    }
    .padding()
}
