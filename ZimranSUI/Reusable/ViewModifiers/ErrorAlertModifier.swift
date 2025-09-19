//
//  ErrorAlertModifier.swift
//  ZimranSUI
//
//  Created by Aikhan on 18.09.2025.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let error: Error?

    init(isPresented: Binding<Bool>, error: Error?) {
        _isPresented = isPresented
        self.error = error
    }

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: _isPresented) {
                Button("OK") { }
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
    }
}

extension View {
    func errorAlert(isPresented: Binding<Bool>, error: Error?) -> some View {
        self.modifier(ErrorAlertModifier(isPresented: isPresented, error: error))
    }
}
