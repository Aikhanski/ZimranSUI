//
//  SearchBar.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    let searchAction: () -> Void
    
    init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSubmit: @escaping () -> Void = {},
        searchAction: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        self.searchAction = searchAction
    }
    
    var body: some View {
        HStack(spacing: .spacingS) {
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, CGFloat.paddingM)
                .padding(.vertical, CGFloat.paddingS)
                .background(Color.secondaryBackground)
                .cornerRadius(.radiusM)
                .onSubmit {
                    onSubmit()
                }
            
            Button(action: searchAction) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.primaryButton)
                    .cornerRadius(.radiusM)
            }
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, CGFloat.paddingL)
        .padding(.vertical, CGFloat.paddingS)
        .background(Color.primaryBackground)
    }
}

#Preview {
    @State var searchText = ""
    
    return VStack(spacing: .spacingL) {
        SearchBar(
            text: $searchText,
            placeholder: "Search users...",
            onSubmit: { print("Submitted: \(searchText)") },
            searchAction: { print("Search tapped: \(searchText)") }
        )
        
        SearchBar(
            text: $searchText,
            placeholder: "Search repositories..."
        )
    }
    .padding()
}
