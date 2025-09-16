//
//  AuthServiceAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

struct AuthServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(AuthCredentialsProvider.self) { _ in
            AuthCredentialsManager()
        }.inObjectScope(.container)
        
        container.register(UserSessionDestroyer.self) { r in
            r.resolve(AuthCredentialsProvider.self) as! AuthCredentialsManager
        }
        
        container.register(AuthProvider.self) { r in
            AuthManager(
                authCredentialsProvider: r.resolve(AuthCredentialsProvider.self)!,
                githubUserProvider: r.resolve(GitHubUserProvider.self)!,
                userSessionDestroyer: r.resolve(UserSessionDestroyer.self)!
            )
        }.inObjectScope(.container)
    }
}
