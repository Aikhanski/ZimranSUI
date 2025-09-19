//
//  Router.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation
import SwiftUI
import Combine

protocol RouterProtocol: ObservableObject {
    var path: [Route] { get set }
    func showAuthentication()
    func showRepositorySearch()
    func showUserSearch()
    func showHistory()
    func showSettings()
    func showUserRepositories()
    func pop()
    func popToRoot()
}

final class Router: RouterProtocol {
    @Published var path: [Route] = []
    
    func showAuthentication() {
        path.removeAll()
        path.append(.authentication)
    }
    
    func showRepositorySearch() {
        path.removeAll()
        path.append(.repositorySearch)
    }
    
    func showUserSearch() {
        path.append(.userSearch)
    }
    
    func showHistory() {
        path.append(.history)
    }
    
    func showSettings() {
        path.append(.profile)
    }
    
    func showUserRepositories() {
        path.append(.userRepositories)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
}
