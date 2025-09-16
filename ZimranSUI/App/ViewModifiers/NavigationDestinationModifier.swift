//
//  NavigationDestinationModifier.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import SwiftUI

struct NavigationDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
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
}
