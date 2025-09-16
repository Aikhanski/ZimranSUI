//
//  OAuthManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI
import Combine
import os.log

final class OAuthManager: NSObject, ObservableObject {
    // MARK: - Configuration
    let clientID = "Ov23liGYXjUvYAKmyGGF"
    let redirectURI = "zimransui://oauth-callback"
    let authorizeEndpoint = "https://github.com/login/oauth/authorize"
    let tokenEndpoint = "https://github.com/login/oauth/access_token"
    let scopes = "read:user user:email repo"
    
    // MARK: - Logging
    private let logger = Logger(subsystem: "com.zimran.app", category: "OAuthManager")
    
    // MARK: - State Management
    private var currentState: String?
    private var currentCodeVerifier: String?
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var user: AuthenticatedUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authSession: ASWebAuthenticationSession?
    
    // MARK: - Public Methods
    func startSignIn() {
        logger.info("🔐 Starting OAuth sign in process")
        isLoading = true
        errorMessage = nil
        
        // 1) Generate state & PKCE
        let state = randomString(length: 32)
        currentState = state
        
        let verifier = generateCodeVerifier()
        currentCodeVerifier = verifier
        let challenge = codeChallenge(for: verifier)
        
        logger.info("🔑 Generated PKCE parameters:")
        logger.info("   State: \(state)")
        logger.info("   Code Verifier: \(verifier)")
        logger.info("   Code Challenge: \(challenge)")
        
        // 2) Build authorize URL
        var components = URLComponents(string: authorizeEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "allow_signup", value: "true"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        guard let authURL = components.url else {
            logger.error("❌ Failed to build authorization URL")
            DispatchQueue.main.async {
                self.errorMessage = "Invalid authorization URL"
                self.isLoading = false
            }
            return
        }
        
        logger.info("🌐 Authorization URL: \(authURL.absoluteString)")
        
        // 3) ASWebAuthenticationSession
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "zimransui") { [weak self] callbackURL, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                self.logger.error("❌ Auth session error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication failed: \(error.localizedDescription)"
                }
                return
            }
            
            self.logger.info("📞 Received callback URL: \(callbackURL?.absoluteString ?? "nil")")
            
            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                self.logger.error("❌ No callback URL or query items")
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication failed: Invalid callback"
                }
                return
            }
            
            let code = queryItems.first(where: { $0.name == "code" })?.value
            let returnedState = queryItems.first(where: { $0.name == "state" })?.value
            
            self.logger.info("🔍 Callback parameters:")
            self.logger.info("   Code: \(code ?? "nil")")
            self.logger.info("   Returned State: \(returnedState ?? "nil")")
            self.logger.info("   Expected State: \(self.currentState ?? "nil")")
            
            // Validate state
            guard returnedState == self.currentState else {
                self.logger.error("❌ State mismatch - expected: \(self.currentState ?? "nil"), received: \(returnedState ?? "nil")")
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication failed: State mismatch"
                }
                return
            }
            
            guard let code = code else {
                self.logger.error("❌ No authorization code in callback")
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication failed: No code received"
                }
                return
            }
            
            // 4) Exchange code for token
            Task {
                await self.exchangeCodeForToken(code: code)
            }
        }
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    // MARK: - Token Exchange
    func exchangeCodeForToken(code: String) async {
        logger.info("🔄 Starting token exchange")
        logger.info("   Authorization Code: \(code)")
        
        guard let verifier = currentCodeVerifier else {
            logger.error("❌ No code verifier available")
            DispatchQueue.main.async {
                self.errorMessage = "No code verifier available"
            }
            return
        }
        
        logger.info("   Code Verifier: \(verifier)")
        
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Body: x-www-form-urlencoded
        let bodyParams = [
            "client_id": clientID,
            "code": code,
            "redirect_uri": redirectURI,
            "code_verifier": verifier
        ]
        
        let bodyString = bodyParams.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        logger.info("🚀 Token Exchange Request:")
        logger.info("   URL: \(self.tokenEndpoint)")
        logger.info("   Method: POST")
        logger.info("   Headers: Accept: application/json")
        logger.info("   Body: \(bodyString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            logger.info("📥 Token Exchange Response:")
            if let http = response as? HTTPURLResponse {
                logger.info("   Status Code: \(http.statusCode)")
                logger.info("   Headers: \(http.allHeaderFields)")
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? "[Binary data]"
            logger.info("   Response Body: \(responseString)")
            
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let errorMessage = "Token exchange failed with status \(http.statusCode)"
                logger.error("❌ \(errorMessage)")
                DispatchQueue.main.async {
                    self.errorMessage = errorMessage
                }
                return
            }
            
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            // Check for GitHub API errors first
            if let error = json?["error"] as? String {
                let errorDescription = json?["error_description"] as? String ?? error
                logger.error("❌ GitHub API Error: \(error) - \(errorDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "GitHub Error: \(errorDescription)"
                }
                return
            }
            
            if let token = json?["access_token"] as? String {
                logger.info("✅ Successfully received access token")
                DispatchQueue.main.async {
                    self.accessToken = token
                    self.isAuthenticated = true
                    // Save token to Keychain
                    self.saveTokenToKeychain(token)
                }
                
                // Fetch user info
                await fetchUserInfo(token: token)
            } else {
                let errorMessage = "No access token in response"
                logger.error("❌ \(errorMessage)")
                DispatchQueue.main.async {
                    self.errorMessage = errorMessage
                }
            }
        } catch {
            logger.error("❌ Token exchange error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Token exchange error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - User Info Fetching
    func fetchUserInfo(token: String) async {
        logger.info("👤 Fetching user info")
        
        var request = URLRequest(url: URL(string: "https://api.github.com/user")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        logger.info("🚀 User Info Request:")
        logger.info("   URL: https://api.github.com/user")
        logger.info("   Method: GET")
        logger.info("   Headers: Authorization: Bearer \(String(token.prefix(8)))...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            logger.info("📥 User Info Response:")
            if let http = response as? HTTPURLResponse {
                logger.info("   Status Code: \(http.statusCode)")
            }
            
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                logger.error("❌ User info endpoint returned status \(http.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    logger.error("   Response: \(responseString)")
                }
                return
            }
            
            let decodedUser = try JSONDecoder().decode(AuthenticatedUser.self, from: data)
            logger.info("✅ Successfully fetched user info: \(decodedUser.login)")
            DispatchQueue.main.async {
                self.user = decodedUser
            }
        } catch {
            logger.error("❌ Failed to fetch user info: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Token Management
    func saveTokenToKeychain(_ token: String) {
        GitHubTokenManager.shared.token = token
    }
    
    func loadTokenFromKeychain() -> String? {
        return GitHubTokenManager.shared.token
    }
    
    func signOut() {
        accessToken = nil
        isAuthenticated = false
        user = nil
        GitHubTokenManager.shared.clearAllTokens()
    }
    
    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String {
        // 43..128 characters recommended
        return randomString(length: 64)
    }
    
    private func codeChallenge(for verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        let digest = Data(hashed)
        return base64URL(digest)
    }
    
    private func base64URL(_ data: Data) -> String {
        var s = data.base64EncodedString()
        s = s.replacingOccurrences(of: "+", with: "-")
        s = s.replacingOccurrences(of: "/", with: "_")
        s = s.replacingOccurrences(of: "=", with: "")
        return s
    }
    
    private func randomString(length: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        var s = ""
        for _ in 0..<length {
            s.append(letters.randomElement()!)
        }
        return s
    }
}

extension OAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Use the first key window
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
