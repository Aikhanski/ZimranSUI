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
        container.register((any RouterProtocol).self) { _ in
            Router()
        }.inObjectScope(.container)
    }
}