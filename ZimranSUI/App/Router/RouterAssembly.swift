//
//  RouterAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

struct RouterAssembly: Assembly {
    func assemble(container: Container) {
        container.register(Router.self) { _ in
            Router()
        }.inObjectScope(.container)
    }
}
