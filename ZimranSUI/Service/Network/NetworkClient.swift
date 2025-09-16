//
//  NetworkClient.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import Combine
import Alamofire

protocol NetworkClient: AnyObject {
    
    func request<Parameters: Encodable, Response: Decodable>(
        _ relativePath: String,
        method: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders?
    ) -> AnyPublisher<Response, Error>
}

extension NetworkClient {
    
    func get<Response: Decodable>(
        _ relativePath: String,
        parameters: some Encodable = EmptyParameters(),
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<Response, Error> {
        request(relativePath, method: .get, parameters: parameters, headers: headers)
    }
    
    func post<Response: Decodable>(
        _ relativePath: String,
        parameters: some Encodable,
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<Response, Error> {
        request(relativePath, method: .post, parameters: parameters, headers: headers)
    }
    
    func delete<Response: Decodable>(
        _ relativePath: String,
        parameters: some Encodable = EmptyParameters(),
        headers: HTTPHeaders? = nil
    ) -> AnyPublisher<Response, Error> {
        request(relativePath, method: .delete, parameters: parameters, headers: headers)
    }
}

// MARK: - Empty Parameters
struct EmptyParameters: Encodable {}
