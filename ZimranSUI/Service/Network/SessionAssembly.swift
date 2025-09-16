//
//  SessionAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject
import Alamofire

struct SessionAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(Session.self) { _ in
            let configuration = URLSessionConfiguration.af.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            
            return Session(configuration: configuration)
        }.inObjectScope(.container)
    }
}
