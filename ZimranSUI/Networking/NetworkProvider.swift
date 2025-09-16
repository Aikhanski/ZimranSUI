//
//  NetworkProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine
import os.log

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
}

class NetworkProvider {
    static let shared = NetworkProvider()
    private let session = URLSession.shared
    private let logger = Logger(subsystem: "com.zimran.app", category: "NetworkProvider")
    
    private init() {}
    
    func request<T: Decodable>(_ target: NetworkTarget, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        guard let url = buildURL(from: target) else {
            logger.error("❌ Invalid URL for target: \(target.path)")
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        
        // Log request details
        logRequest(request, target: target)
        
        return session.dataTaskPublisher(for: request)
            .handleEvents(
                receiveOutput: { [weak self] data, response in
                    self?.logResponse(data: data, response: response, url: url)
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("❌ Request failed: \(error.localizedDescription)")
                    }
                }
            )
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        throw NetworkError.serverError(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func buildURL(from target: NetworkTarget) -> URL? {
        var components = URLComponents(url: target.baseURL.appendingPathComponent(target.path), resolvingAgainstBaseURL: false)
        
        if let parameters = target.parameters {
            components?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: String(describing: value))
            }
        }
        
        return components?.url
    }
    
    // MARK: - Logging Methods
    
    private func logRequest(_ request: URLRequest, target: NetworkTarget) {
        logger.info("🚀 REQUEST START")
        logger.info("📍 URL: \(request.url?.absoluteString ?? "nil")")
        logger.info("🔧 Method: \(request.httpMethod ?? "nil")")
        
        // Log headers
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.info("📋 Headers:")
            for (key, value) in headers {
                // Mask sensitive headers
                let maskedValue = maskSensitiveHeader(key: key, value: value)
                logger.info("   \(key): \(maskedValue)")
            }
        } else {
            logger.info("📋 Headers: None")
        }
        
        // Log body if present
        if let body = request.httpBody {
            if let bodyString = String(data: body, encoding: .utf8) {
                logger.info("📦 Body: \(bodyString)")
            } else {
                logger.info("📦 Body: [Binary data, \(body.count) bytes]")
            }
        } else {
            logger.info("📦 Body: None")
        }
        
        // Log query parameters
        if let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems, !queryItems.isEmpty {
            logger.info("🔍 Query Parameters:")
            for item in queryItems {
                logger.info("   \(item.name): \(item.value ?? "nil")")
            }
        }
        
        logger.info("🚀 REQUEST END")
    }
    
    private func logResponse(data: Data, response: URLResponse, url: URL) {
        logger.info("📥 RESPONSE START")
        logger.info("📍 URL: \(url.absoluteString)")
        
        if let httpResponse = response as? HTTPURLResponse {
            logger.info("📊 Status Code: \(httpResponse.statusCode)")
            logger.info("📋 Response Headers:")
            for (key, value) in httpResponse.allHeaderFields {
                logger.info("   \(key): \(String(describing: value))")
            }
        }
        
        // Log response body
        if let responseString = String(data: data, encoding: .utf8) {
            logger.info("📦 Response Body: \(responseString)")
        } else {
            logger.info("📦 Response Body: [Binary data, \(data.count) bytes]")
        }
        
        logger.info("📥 RESPONSE END")
    }
    
    private func maskSensitiveHeader(key: String, value: String) -> String {
        let sensitiveKeys = ["authorization", "x-api-key", "token", "password"]
        let lowercasedKey = key.lowercased()
        
        if sensitiveKeys.contains(where: { lowercasedKey.contains($0) }) {
            // Show first 8 characters and mask the rest
            if value.count > 8 {
                let prefix = String(value.prefix(8))
                let masked = String(repeating: "*", count: value.count - 8)
                return "\(prefix)\(masked)"
            } else {
                return String(repeating: "*", count: value.count)
            }
        }
        
        return value
    }
}
