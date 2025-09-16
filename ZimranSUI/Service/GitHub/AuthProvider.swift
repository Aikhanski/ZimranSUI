//
//  AuthProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine

protocol AuthProvider {
    var isAuthenticated: Bool { get }
    var currentUser: AuthenticatedUser? { get }
    
    func authenticateWithToken(_ token: String) -> AnyPublisher<AuthenticatedUser, Error>
    func authenticateWithOAuth() -> AnyPublisher<AuthenticatedUser, Error>
    func signOut()
}
