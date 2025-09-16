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
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let token = authCredentialsProvider.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }
}
