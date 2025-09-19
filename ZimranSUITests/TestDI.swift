//
//  TestDI.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Foundation
import Swinject
@testable import ZimranSUI

final class TestDI {
    static func makeContainer() -> Container {
        let container = Container()
        MockDependencyContainerAssembly().assemble(container: container)
        return container
    }
}
