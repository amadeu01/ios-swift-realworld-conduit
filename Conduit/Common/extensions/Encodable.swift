//
//  Encodable.swift
//  RD
//
//  Created by Amadeu Cavalcante Filho on 07/02/19.
//  Copyright © 2019 Pixeon Medical Systems. All rights reserved.
//
import Foundation

public extension Encodable {
    func encode() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        return try? encoder.encode(self)
    }
}
