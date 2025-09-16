//
//  NetworkClientImpl.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine
import Alamofire

final class NetworkClientImpl: NetworkClient {
    private let session: Session
    private let baseURLProvider: BaseURLProvider
    
    init(session: Session, baseURLProvider: BaseURLProvider) {
        self.session = session
        self.baseURLProvider = baseURLProvider
    }
    
    func request<Parameters: Encodable, Response: Decodable>(
        _ relativePath: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders?
    ) -> AnyPublisher<Response, Error> {
        let url = baseURLProvider.baseURL + relativePath
        
        let request: DataRequest
        
        // Debug logging
        print("🌐 NetworkClient making request to: \(url)")
        print("   Method: \(method)")
        print("   Parameters: \(parameters is EmptyParameters ? "none" : "present")")
        
        // Check if parameters are empty
        if parameters is EmptyParameters {
            request = session.request(url, method: method, headers: headers)
        } else {
            request = session.request(
                url,
                method: method,
                parameters: parameters,
                encoder: ParameterEncoderFactory().makeParameterEncoder(for: method),
                headers: headers
            )
        }
        
        return request
            .validate(contentType: ["application/json", "application/vnd.github+json"])
            .publishDecodable(type: Response.self)
            .value()
            .handleEvents(
                receiveOutput: { response in
                    print("✅ Request successful:")
                    print("   URL: \(url)")
                    print("   Method: \(method)")
                    print("   Response type: \(Response.self)")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ Request completed successfully")
                    case .failure(let error):
                        print("❌ Request failed:")
                        print("   URL: \(url)")
                        print("   Method: \(method)")
                        print("   Error: \(error)")
                        if let afError = error as? AFError {
                            print("   AFError details: \(afError)")
                            switch afError {
                            case .responseValidationFailed(reason: .unacceptableStatusCode(code: let code)):
                                print("   Response status: \(code)")
                            case .responseValidationFailed(reason: .customValidationFailed(error: let customError)):
                                print("   Custom validation error: \(customError)")
                            default:
                                print("   Other AFError: \(afError)")
                            }
                        }
                    }
                }
            )
            .mapError { error in
                if let afError = error as? AFError {
                    return NetworkError.alamofireError(afError)
                }
                return NetworkError.unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Parameter Encoder Factory
struct ParameterEncoderFactory {
    func makeParameterEncoder(for method: HTTPMethod) -> ParameterEncoder {
        switch method {
        case .get, .delete:
            return URLEncodedFormParameterEncoder.default
        case .post, .put, .patch:
            return JSONParameterEncoder.default
        default:
            return URLEncodedFormParameterEncoder.default
        }
    }
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case alamofireError(AFError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .alamofireError(let error):
            return error.localizedDescription
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
