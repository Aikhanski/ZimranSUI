//
//  ButtonStyles.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    init(isLoading: Bool = false) {
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonRegular)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(CGFloat.paddingL)
            .background(Color.primaryButton)
            .cornerRadius(.radiusM)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    init(isLoading: Bool = false) {
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonRegular)
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .padding(CGFloat.paddingL)
            .background(Color.secondaryButton)
            .cornerRadius(.radiusM)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryText))
                            .scaleEffect(0.8)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    init(isLoading: Bool = false) {
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonRegular)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(CGFloat.paddingL)
            .background(Color.destructiveButton)
            .cornerRadius(.radiusM)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

struct GhostButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    init(isLoading: Bool = false) {
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonRegular)
            .foregroundColor(.primaryButton)
            .frame(maxWidth: .infinity)
            .padding(CGFloat.paddingL)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: .radiusM)
                    .stroke(Color.primaryButton, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryButton))
                            .scaleEffect(0.8)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

extension View {
    func primaryButtonStyle(isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isLoading: isLoading))
    }
    
    func secondaryButtonStyle(isLoading: Bool = false) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isLoading: isLoading))
    }
    
    func destructiveButtonStyle(isLoading: Bool = false) -> some View {
        self.buttonStyle(DestructiveButtonStyle(isLoading: isLoading))
    }
    
    func ghostButtonStyle(isLoading: Bool = false) -> some View {
        self.buttonStyle(GhostButtonStyle(isLoading: isLoading))
    }
}
