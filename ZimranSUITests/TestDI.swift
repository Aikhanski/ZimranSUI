//
//  TestDI.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Foundation
import Swinject
@testable import ZimranSUI

/// Централизованная инициализация DI контейнера для тестов
final class TestDI {
    /// Создает новый контейнер для каждого теста
    static func makeContainer() -> Container {
        let container = Container()
        MockDependencyContainerAssembly().assemble(container: container)
        return container
    }
}
