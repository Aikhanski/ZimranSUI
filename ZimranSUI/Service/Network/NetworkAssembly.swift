//
//  NetworkAssembly.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Swinject
import Alamofire

struct NetworkAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(NetworkClient.self) { r in
            let configuration = URLSessionConfiguration.af.default
            configuration.timeoutIntervalForRequest = 30
            
            let adapter = NetworkAdapter(
                authCredentialsProvider: r.resolve(AuthCredentialsProvider.self)!
            )
            let retrier = NetworkRetrier(
                userSessionDestroyer: r.resolve(UserSessionDestroyer.self)!
            )
            
            let session = Session(
                configuration: configuration,
                interceptor: Interceptor(adapter: adapter, retrier: retrier)
            )
            
            return NetworkClientImpl(
                session: session,
                baseURLProvider: r.resolve(BaseURLProvider.self)!
            )
        }.inObjectScope(.weak)
    }
}
