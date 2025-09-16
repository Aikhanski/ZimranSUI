//
//  AuthManager.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine
import AuthenticationServices
import CryptoKit

final class AuthManager: NSObject, AuthProvider, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthenticatedUser?
    
    private let authCredentialsProvider: AuthCredentialsProvider
    private let githubUserProvider: GitHubUserProvider
    private let userSessionDestroyer: UserSessionDestroyer
    
    // OAuth configuration
    private let clientID = "Ov23liEI45VHtjMirJdp"
    private let redirectURI = "zimransui://oauth-callback"
    private let authorizeEndpoint = "https://github.com/login/oauth/authorize"
    private let tokenEndpoint = "https://github.com/login/oauth/access_token"
    private let scopes = "read:user user:email repo"
    
    private var currentState: String?
    private var currentCodeVerifier: String?
    private var authSession: ASWebAuthenticationSession?
    
    init(
        authCredentialsProvider: AuthCredentialsProvider,
        githubUserProvider: GitHubUserProvider,
        userSessionDestroyer: UserSessionDestroyer
    ) {
        self.authCredentialsProvider = authCredentialsProvider
        self.githubUserProvider = githubUserProvider
        self.userSessionDestroyer = userSessionDestroyer
        super.init()
        
        // Check if already authenticated
        if authCredentialsProvider.token != nil {
            isAuthenticated = true
            Task {
                await loadUserInfo()
            }
        }
    }
    
    func authenticateWithToken(_ token: String) -> AnyPublisher<AuthenticatedUser, Error> {
        authCredentialsProvider.setToken(token)
        
        return githubUserProvider.getAuthenticatedUser()
            .handleEvents(receiveOutput: { [weak self] user in
                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            })
            .eraseToAnyPublisher()
    }
    
    func authenticateWithOAuth() -> AnyPublisher<AuthenticatedUser, Error> {
        return Future<AuthenticatedUser, Error> { [weak self] promise in
            self?.startOAuthFlow(promise: promise)
        }.eraseToAnyPublisher()
    }
    
    func signOut() {
        authCredentialsProvider.clearToken()
        currentUser = nil
        isAuthenticated = false
        userSessionDestroyer.destroySession()
    }
    
    private func loadUserInfo() {
        guard authCredentialsProvider.token != nil else { return }
        
        githubUserProvider.getAuthenticatedUser()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            )
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private func startOAuthFlow(promise: @escaping (Result<AuthenticatedUser, Error>) -> Void) {
        // Generate state & PKCE
        let state = randomString(length: 32)
        currentState = state
        
        let verifier = generateCodeVerifier()
        currentCodeVerifier = verifier
        let challenge = codeChallenge(for: verifier)
        
        print("🔐 OAuth Flow Start:")
        print("   State: \(state)")
        print("   Code Verifier: \(verifier)")
        print("   Code Challenge: \(challenge)")
        print("   Client ID: \(clientID)")
        print("   Redirect URI: \(redirectURI)")
        print("   Scopes: \(scopes)")
        
        // Build authorize URL
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
            promise(.failure(AuthError.invalidURL))
            return
        }
        
        // Start authentication session
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "zimransui") { [weak self] callbackURL, error in
            if let error = error {
                promise(.failure(error))
                return
            }
            
            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                promise(.failure(AuthError.invalidCallback))
                return
            }
            
            let code = queryItems.first(where: { $0.name == "code" })?.value
            let returnedState = queryItems.first(where: { $0.name == "state" })?.value
            
            // Validate state
            guard returnedState == self?.currentState else {
                promise(.failure(AuthError.stateMismatch))
                return
            }
            
            guard let code = code else {
                promise(.failure(AuthError.noCode))
                return
            }
            
            // Exchange code for token
            Task {
                do {
                    let token = try await self?.exchangeCodeForToken(code: code)
                    if let token = token {
                        let user = try await self?.getUserWithToken(token)
                        if let user = user {
                            DispatchQueue.main.async {
                                promise(.success(user))
                            }
                        } else {
                            DispatchQueue.main.async {
                                promise(.failure(AuthError.userFetchFailed))
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            promise(.failure(AuthError.tokenExchangeFailed))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
        
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }
    
    private func exchangeCodeForToken(code: String) async throws -> String? {
        guard let verifier = currentCodeVerifier else {
            throw AuthError.noCodeVerifier
        }
        
        print("🔐 OAuth Token Exchange:")
        print("   Client ID: \(clientID)")
        print("   Redirect URI: \(redirectURI)")
        print("   Code: \(code)")
        print("   Code Verifier: \(verifier)")
        print("   Token Endpoint: \(tokenEndpoint)")
        
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "client_id": clientID,
            "code": code,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code",
            "code_verifier": verifier
        ]
        
        let bodyString = bodyParams.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        
        print("   Request Body: \(bodyString)")
        print("   Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("   Response Status: \(http.statusCode)")
            print("   Response Headers: \(http.allHeaderFields)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Response Body: \(responseString)")
        }
        
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw AuthError.tokenExchangeFailed
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        if let error = json?["error"] as? String {
            let errorDescription = json?["error_description"] as? String ?? error
            print("   GitHub Error: \(error) - \(errorDescription)")
            throw AuthError.gitHubError(errorDescription)
        }
        
        if let token = json?["access_token"] as? String {
            print("   ✅ Access Token received: \(String(token.prefix(10)))...")
            authCredentialsProvider.setToken(token)
            return token
        }
        
        throw AuthError.noToken
    }
    
    private func getUserWithToken(_ token: String) async throws -> AuthenticatedUser? {
        // Use our NetworkClient which has proper headers configured
        return try await withCheckedThrowingContinuation { continuation in
            githubUserProvider.getAuthenticatedUser()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { user in
                        continuation.resume(returning: user)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String {
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
    
    // MARK: - Debug Functions
    func testPKCE() {
        let verifier = generateCodeVerifier()
        let challenge = codeChallenge(for: verifier)
        
        print("🧪 PKCE Test:")
        print("   Verifier: \(verifier)")
        print("   Challenge: \(challenge)")
        print("   Verifier length: \(verifier.count)")
        print("   Challenge length: \(challenge.count)")
        
        // Verify challenge is correct
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        let digest = Data(hashed)
        let expectedChallenge = base64URL(digest)
        
        print("   Expected challenge: \(expectedChallenge)")
        print("   Challenge matches: \(challenge == expectedChallenge)")
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case invalidURL
    case invalidCallback
    case stateMismatch
    case noCode
    case noCodeVerifier
    case tokenExchangeFailed
    case noToken
    case userFetchFailed
    case gitHubError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid authorization URL"
        case .invalidCallback:
            return "Invalid callback URL"
        case .stateMismatch:
            return "State mismatch in OAuth flow"
        case .noCode:
            return "No authorization code received"
        case .noCodeVerifier:
            return "No code verifier available"
        case .tokenExchangeFailed:
            return "Token exchange failed"
        case .noToken:
            return "No access token received"
        case .userFetchFailed:
            return "Failed to fetch user information"
        case .gitHubError(let message):
            return "GitHub Error: \(message)"
        }
    }
}

extension AuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
