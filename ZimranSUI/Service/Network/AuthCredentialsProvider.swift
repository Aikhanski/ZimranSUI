//
//  AuthCredentialsProvider.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

protocol AuthCredentialsProvider {
    var token: String? { get }
    func setToken(_ token: String?)
    func clearToken()
}
