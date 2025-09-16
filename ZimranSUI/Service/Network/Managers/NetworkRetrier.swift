//
//  NetworkRetrier.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Alamofire

final class NetworkRetrier: RequestRetrier {
    
    private let userSessionDestroyer: UserSessionDestroyer
    
    init(userSessionDestroyer: UserSessionDestroyer) {
        self.userSessionDestroyer = userSessionDestroyer
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        switch response.statusCode {
        case 401:
            userSessionDestroyer.destroySession()
            completion(.doNotRetry)
        case 403:
            completion(.retryWithDelay(2.0))
        case 429:
            completion(.retryWithDelay(5.0))
        default:
            completion(.doNotRetry)
        }
    }
}

// MARK: - User Session Destroyer Protocol
protocol UserSessionDestroyer {
    func destroySession()
}
