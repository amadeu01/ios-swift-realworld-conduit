import Foundation

public struct Session: Codable {
    let jwt: String
}

extension Session {
    var token: String {
        return "Token \(jwt)"
    }
}
