//
//  Decodable.swift
//  Conduit
//
//  Created by Amadeu Cavalcante Filho on 23/05/19.
//  Copyright © 2019 Amadeu. All rights reserved.
//

import Foundation

public extension Data {
    func decode<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        return try? decoder.decode(T.self, from: self)
    }

    func decode<T: Decodable>() -> Result<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        return .init {
            return try decoder.decode(T.self, from: self)
        }
    }
}
