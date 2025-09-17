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
                case .profile:
                    ProfileView()
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
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authProvider: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if authProvider.isAuthenticated {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 20)

                        if let user = authProvider.currentUser {
                            AsyncImage(url: URL(string: user.avatarURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            
                            VStack(spacing: 8) {
                                Text(user.name ?? user.login)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("@\(user.login)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Authenticated")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    Spacer()
                    
                    VStack {
                        Divider()
                        
                        Button(action: {
                            authProvider.signOut()
                        }) {
                            Text("Log Out")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .background(Color(.systemBackground))
                } else {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Not Authenticated")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Sign in to access your GitHub profile")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
