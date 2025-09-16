//
//  GitHubServiceAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

struct GitHubServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GitHubRepositoryProvider.self) { r in
            GitHubRepositoryManager(
                networkClient: r.resolve(NetworkClient.self)!
            )
        }
        
        container.register(GitHubUserProvider.self) { r in
            GitHubUserManager(
                networkClient: r.resolve(NetworkClient.self)!
            )
        }
    }
}
