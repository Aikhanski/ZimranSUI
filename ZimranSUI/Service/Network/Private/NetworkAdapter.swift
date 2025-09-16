//
//  NetworkAdapter.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Alamofire

final class NetworkAdapter: RequestAdapter {
    private let authCredentialsProvider: AuthCredentialsProvider
    
    init(authCredentialsProvider: AuthCredentialsProvider) {
        self.authCredentialsProvider = authCredentialsProvider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // Debug logging
        print("🔧 NetworkAdapter processing request:")
        print("   URL: \(request.url?.absoluteString ?? "unknown")")
        print("   Method: \(request.httpMethod ?? "unknown")")
        print("   Original headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Add GitHub API headers
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        // Add authorization header if token is available
        if let token = authCredentialsProvider.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("   Final headers: \(request.allHTTPHeaderFields ?? [:])")
        print("   Body: \(request.httpBody != nil ? "present (\(request.httpBody?.count ?? 0) bytes)" : "none")")
        
        completion(.success(request))
    }
}
