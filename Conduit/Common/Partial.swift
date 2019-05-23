//
//  Partial.swift
//  Common
//
//  Created by Amadeu Cavalcante Filho on 27/03/19.
//  Copyright © 2019 Pixeon Medical Systems. All rights reserved.
//

import Foundation

public struct Partial<T> {
    public enum Error: Swift.Error {
        case valueNotFound
    }

    public init() {}

    private var data: [PartialKeyPath<T>: Any] = [:]

    public mutating func update<U>(_ keyPath: KeyPath<T, U>, to newValue: U?) {
        data[keyPath] = newValue
    }
    public mutating func update<U>(_ keyPath: KeyPath<T, U?>, to newValue: U?) {
        data[keyPath] = newValue
    }

    public func value<U>(for keyPath: KeyPath<T, U>) throws -> U {
        guard let value = data[keyPath] as? U else { throw Error.valueNotFound }
        return value
    }

    public func value<U>(for keyPath: KeyPath<T, U?>) -> U? {
        return data[keyPath] as? U
    }

    public func value<U, V>(for keyPath: KeyPath<T, U>, _ inner: KeyPath<U, V>) throws -> V {
        let root = try value(for: keyPath)
        return root[keyPath: inner]
    }
    
    public func value<U, V>(for keyPath: KeyPath<T, U?>, _ inner: KeyPath<U, V>) -> V? {
        guard let root = value(for: keyPath) else { return nil }
        return root[keyPath: inner]
    }
}
