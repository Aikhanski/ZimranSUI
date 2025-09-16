//
//  ContentView.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authProvider = DependencyContainer.shared.resolve(AuthProvider.self) as! AuthManager
    @StateObject private var router = DependencyContainer.shared.resolve(Router.self)!
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if authProvider.isAuthenticated {
                    MainTabView()
                } else {
                    AuthenticationView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .authentication:
                    AuthenticationView()
                case .repositorySearch:
                    RepositorySearchView()
                case .userSearch:
                    SearchView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                case .userRepositories:
                    UserRepositoriesView()
                }
            }
        }
        .environmentObject(authProvider)
        .environmentObject(router)
    }
}

struct MainTabView: View {
    @EnvironmentObject var authProvider: AuthManager
    @EnvironmentObject var router: Router
    
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
    @EnvironmentObject var authProvider: AuthManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Authentication") {
                    if authProvider.isAuthenticated {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Authenticated")
                            Spacer()
                            Button("Sign Out") {
                                authProvider.signOut()
                            }
                            .foregroundColor(.red)
                        }
                        
                        if let user = authProvider.currentUser {
                            HStack {
                                AsyncImage(url: URL(string: user.avatarURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(user.name ?? user.login)
                                        .font(.headline)
                                    Text("@\(user.login)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
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
