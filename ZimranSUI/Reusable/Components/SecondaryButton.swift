//
//  SecondaryButton.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let systemIcon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        systemIcon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemIcon = systemIcon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: .spacingS) {
                if let systemIcon = systemIcon, !isLoading {
                    Image(systemName: systemIcon)
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryText))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                }
            }
        }
        .secondaryButtonStyle(isLoading: isLoading)
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: .spacingL) {
        SecondaryButton(title: "Use Personal Access Token", systemIcon: "key") {
            print("Secondary button tapped")
        }
        
        SecondaryButton(title: "Loading...", isLoading: true) {
            print("Loading button tapped")
        }
        
        SecondaryButton(title: "Disabled", isDisabled: true) {
            print("Disabled button tapped")
        }
    }
    .padding()
}
