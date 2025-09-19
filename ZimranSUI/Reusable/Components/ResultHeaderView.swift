//
//  ResultHeaderView.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct ResultHeaderView: View {
    let totalCount: Int
    let isLoading: Bool
    
    var body: some View {
        HStack {
            if isLoading {
                HStack(spacing: .spacingS) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.captionRegular)
                        .foregroundColor(.secondaryText)
                }
            } else {
                Text("\(totalCount) repositories found")
                    .font(.captionRegular)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, CGFloat.paddingL)
        .padding(.vertical, CGFloat.paddingXS)
    }
}

#Preview {
    VStack(spacing: .spacingL) {
        ResultHeaderView(totalCount: 1234, isLoading: false)
        ResultHeaderView(totalCount: 0, isLoading: true)
    }
    .padding()
}
