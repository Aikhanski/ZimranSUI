//
//  ErrorLabel.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct ErrorLabel: View {
    let message: String
    let systemIcon: String
    
    init(message: String, systemIcon: String = "exclamationmark.triangle.fill") {
        self.message = message
        self.systemIcon = systemIcon
    }
    
    var body: some View {
        HStack(spacing: .spacingS) {
            Image(systemName: systemIcon)
                .foregroundColor(.error)
                .font(.caption)
            
            Text(message)
                .font(.captionRegular)
                .foregroundColor(.error)
                .multilineTextAlignment(.leading)
        }
        .padding(CGFloat.paddingS)
        .background(Color.error.opacity(0.1))
        .cornerRadius(.radiusS)
        .overlay(
            RoundedRectangle(cornerRadius: .radiusS)
                .stroke(Color.error.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: .spacingL) {
        ErrorLabel(message: "This is an error message")
        
        ErrorLabel(message: "Network connection failed", systemIcon: "wifi.slash")
        
        ErrorLabel(message: "Invalid credentials provided", systemIcon: "lock.fill")
    }
    .padding()
}
