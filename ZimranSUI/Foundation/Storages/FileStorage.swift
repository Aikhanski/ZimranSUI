//
//  FileStorage.swift
//  ZimranSUI
//
//  Created by Aikhan on 15.09.2025.
//

import Foundation

@propertyWrapper
public struct FileStorage<T: Codable & Equatable> {
    public var wrappedValue: T? {
        didSet {
            guard oldValue != wrappedValue else { return }
            updateWrappedValue()
        }
    }
    
    private let directory: DiskDirectory
    private let path: String
    private let disk = Disk()
    
    public init(directory: DiskDirectory = .caches, path: String) {
        self.directory = directory
        self.path = path
        self.wrappedValue = try? disk.retrieve(path, from: directory, as: T.self)
    }
    
    private func updateWrappedValue() {
        if let wrappedValue {
            try? disk.save(wrappedValue, to: directory, as: path)
        } else {
            try? disk.remove(path, from: directory)
        }
    }
}

public enum DiskDirectory {
    case documents
    case caches
    case applicationSupport
    case temporary
    
    var url: URL {
        switch self {
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .caches:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        case .applicationSupport:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        case .temporary:
            return FileManager.default.temporaryDirectory
        }
    }
}

public class Disk {
    public init() {}
    
    public func save<T: Codable>(_ object: T, to directory: DiskDirectory, as fileName: String) throws {
        let url = directory.url.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    public func retrieve<T: Codable>(_ fileName: String, from directory: DiskDirectory, as type: T.Type) throws -> T {
        let url = directory.url.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func remove(_ fileName: String, from directory: DiskDirectory) throws {
        let url = directory.url.appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: url)
    }
}
