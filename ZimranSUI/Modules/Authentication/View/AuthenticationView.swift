//
//  AuthenticationView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showingTokenInput = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: .spacingXL) {
                headerSection
                descriptionSection
                actionSection
                
                if viewModel.showError, let error = viewModel.error {
                    ErrorLabel(message: error.localizedDescription)
                        .padding(.horizontal, CGFloat.paddingL)
                }
                
                Spacer()
            }
            .padding(CGFloat.paddingL)
            .navigationTitle("Welcome")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTokenInput) {
                TokenInputView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Sections
    private var headerSection: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(.accentBlue)
    }
    
    private var descriptionSection: some View {
        VStack(spacing: .spacingS) {
            Text("GitHub Authentication")
                .font(.titleLarge)
            
            Text("Choose your preferred authentication method")
                .font(.bodyRegular)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CGFloat.paddingL)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: .spacingL) {
            PrimaryButton(
                title: "Sign in with GitHub",
                systemIcon: "globe",
                isLoading: viewModel.isLoading,
                action: viewModel.authenticateWithOAuth
            )
            
            DividerWithText(text: "or")
            
            SecondaryButton(
                title: "Use Personal Access Token",
                systemIcon: "key"
            ) {
                showingTokenInput = true
            }
        }
        .padding(.horizontal, CGFloat.paddingL)
    }
}

struct TokenInputView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: .spacingXL) {
                headerSection
                inputSection
                
                if viewModel.showError, let error = viewModel.error {
                    ErrorLabel(message: error.localizedDescription)
                        .padding(.horizontal, CGFloat.paddingL)
                }
                
                actionSection
                
                Spacer()
            }
            .padding(CGFloat.paddingL)
            .navigationTitle("Token Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    private var headerSection: some View {
        VStack(spacing: .spacingS) {
            Text("Personal Access Token")
                .font(.titleMedium)
            
            Text("Enter your GitHub Personal Access Token")
                .font(.bodyRegular)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CGFloat.paddingL)
        }
    }
    
    private var inputSection: some View {
        SecureField("Personal Access Token", text: $viewModel.token)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, CGFloat.paddingL)
    }
    
    private var actionSection: some View {
        PrimaryButton(
            title: "Sign In",
            isLoading: viewModel.isLoading,
            isDisabled: viewModel.token.isEmpty
        ) {
            viewModel.authenticateWithToken()
            dismiss()
        }
        .padding(.horizontal, CGFloat.paddingL)
    }
}

#Preview {
    AuthenticationView()
}
