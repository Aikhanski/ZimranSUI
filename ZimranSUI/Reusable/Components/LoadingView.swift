//
//  LoadingView.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    let size: CGFloat
    
    init(message: String = "Loading...", size: CGFloat = 1.0) {
        self.message = message
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: .spacingL) {
            ProgressView()
                .scaleEffect(size)
            
            Text(message)
                .font(.bodyRegular)
                .foregroundColor(.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
    }
}

struct LoadingOverlay: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: .spacingS) {
                ProgressView()
                    .scaleEffect(0.8)
                
                if let message = message {
                    Text(message)
                        .font(.captionRegular)
                        .foregroundColor(.secondaryText)
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: .spacingXXL) {
        LoadingView(message: "Searching...")
        
        LoadingView(message: "Loading repositories", size: 1.2)
        
        LoadingOverlay(message: "Loading more...")
            .background(Color.gray.opacity(0.1))
    }
    .padding()
}
