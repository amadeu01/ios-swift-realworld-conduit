//
//  ServerError.swift
//  Conduit
//
//  Created by Amadeu Cavalcante Filho on 23/05/19.
//  Copyright © 2019 Amadeu. All rights reserved.
//

import Foundation

public struct ServerError: Codable {
    let errors: Errors

    public struct Errors: Codable {
        let body: [String]
    }
}
