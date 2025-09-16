//
//  ContentView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var oauthManager = OAuthManager()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated || oauthManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .environmentObject(authViewModel)
        .environmentObject(oauthManager)
    }
}

struct MainTabView: View {
    @EnvironmentObject var oauthManager: OAuthManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            RepositorySearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Repositories")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Users")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var oauthManager: OAuthManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Authentication") {
                    if oauthManager.isAuthenticated {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("OAuth Authentication")
                            Spacer()
                            Button("Sign Out") {
                                oauthManager.signOut()
                            }
                            .foregroundColor(.red)
                        }
                    } else if authViewModel.isAuthenticated {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                            Text("Personal Access Token")
                            Spacer()
                            Button("Sign Out") {
                                authViewModel.logout()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section("GitHub Token") {
                    GitHubTokenSettingsView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
