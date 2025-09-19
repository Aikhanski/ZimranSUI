//
//  MockInjector.swift
//  ZimranSUITests
//
//  Created by Aikhan on 18.09.2025.
//

import Foundation
import Swinject
import SwiftUI
import Combine
@testable import ZimranSUI

protocol MockInjector {
    func injectedMock<T>(for type: T.Type) -> T
}

extension MockInjector {
    
    func injectedMock<T>(for type: T.Type) -> T {
        let container = TestDI.makeContainer()
        guard let resolved = container.resolve(type) else {
            fatalError("Failed to resolve \(type)")
        }
        return resolved
    }
}
struct MockTestUtils {
    
    static func getMock<T>(_ type: T.Type) -> T {
        let container = TestDI.makeContainer()
        guard let resolved = container.resolve(type) else {
            fatalError("Failed to resolve \(type)")
        }
        return resolved
    }
}
extension MockInjector {
    
    var mockAuthProvider: AuthProvider {
        return injectedMock(for: AuthProvider.self)
    }
    
    var mockGitHubUserProvider: GitHubUserProvider {
        return injectedMock(for: GitHubUserProvider.self)
    }
    
    var mockGitHubRepositoryProvider: GitHubRepositoryProvider {
        return injectedMock(for: GitHubRepositoryProvider.self)
    }
    
    var mockNetworkClient: NetworkClient {
        return injectedMock(for: NetworkClient.self)
    }
    
    var mockHistoryStorageProvider: HistoryStorageProvider {
        return injectedMock(for: HistoryStorageProvider.self)
    }
    
    var mockRouter: any RouterProtocol {
        return injectedMock(for: (any RouterProtocol).self)
    }
    
    var mockRepositorySearchService: RepositorySearchServiceProtocol {
        return injectedMock(for: RepositorySearchServiceProtocol.self)
    }
}

open class MockTestBase: MockInjector {
    
    open func setUpMocks() {
    }
    
    open func tearDownMocks() {
    }
}
