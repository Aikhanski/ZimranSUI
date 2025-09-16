//
//  GitHubTokenManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

// MARK: - GitHubTokenManager
class GitHubTokenManager {
    static let shared = GitHubTokenManager()
    private let userDefaultsKey = "github_personal_access_token"
    
    var token: String? {
        get {
            // First try to get from Keychain (OAuth)
            if let keychainToken = loadTokenFromKeychain() {
                return keychainToken
            }
            // Fallback to UserDefaults (Personal Access Token)
            return UserDefaults.standard.string(forKey: userDefaultsKey)
        }
        set {
            if let token = newValue {
                // Save to both Keychain and UserDefaults
                saveTokenToKeychain(token)
                UserDefaults.standard.set(token, forKey: userDefaultsKey)
            } else {
                // Remove from both
                removeTokenFromKeychain()
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }
    
    private init() {}
    
    // MARK: - Keychain Methods
    private func saveTokenToKeychain(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "github_access_token",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "github_access_token",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        
        return nil
    }
    
    private func removeTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "github_access_token"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func clearAllTokens() {
        removeTokenFromKeychain()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
