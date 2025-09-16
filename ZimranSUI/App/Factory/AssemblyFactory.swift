//
//  AssemblyFactory.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject

final class AssemblerFactory {
    func makeAssembler() -> Assembler {
        Assembler([
            SessionAssembly(),
            BaseURLAssembly(),
            NetworkAssembly(),
            GitHubServiceAssembly(),
            AuthServiceAssembly(),
            StorageAssembly(),
            RouterAssembly()
        ])
    }
}
