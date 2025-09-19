//
//  AuthCredentialsManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 16.09.2025.
//

import Foundation

extension Notification.Name {
    static let tokenUpdated = Notification.Name("tokenUpdated")
}

final class AuthCredentialsManager: AuthCredentialsProvider, UserSessionDestroyer {
    @ProtectedStorage(key: "github_access_token")
    private var accessToken: String?
    
    var token: String? {
        accessToken
    }
    
    func setToken(_ token: String?) {
        accessToken = token
        NotificationCenter.default.post(name: .tokenUpdated, object: nil)
    }
    
    func clearToken() {
        accessToken = nil
        NotificationCenter.default.post(name: .tokenUpdated, object: nil)
    }
    
    func destroySession() {
        clearToken()
    }
}
