//
//  DividerWithText.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct DividerWithText: View {
    let text: String
    let color: Color
    
    init(text: String, color: Color = .secondaryText) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.borderSecondary)
            
            Text(text)
                .font(.captionRegular)
                .foregroundColor(color)
                .padding(.horizontal, CGFloat.paddingL)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.borderSecondary)
        }
        .padding(.horizontal, CGFloat.paddingL)
    }
}

#Preview {
    VStack(spacing: .spacingL) {
        DividerWithText(text: "or")
        
        DividerWithText(text: "separator", color: .primaryText)
        
        DividerWithText(text: "custom", color: .accentBlue)
    }
    .padding()
}
