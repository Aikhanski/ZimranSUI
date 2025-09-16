//
//  BaseURLAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

struct BaseURLAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(BaseURLProvider.self) { _ in
            GitHubBaseURLProvider()
        }
    }
}

struct GitHubBaseURLProvider: BaseURLProvider {
    var baseURL: String {
        "https://api.github.com"
    }
}
