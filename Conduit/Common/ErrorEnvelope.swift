import Foundation

public struct ErrorEnvelope: Error {
    public let httpCode: Int
    public let errorMessage: String
    public let serverError: Decodable?
    public let error: Swift.Error?

    public init(decodable serverError: Decodable?, data: Data, urlResponse: HTTPURLResponse) {
        self.error = nil
        self.httpCode = urlResponse.statusCode
        self.serverError = serverError
        self.errorMessage = "Raw message: \(data.rawString)"
    }

    public init(httpCode: Int,
                errorMessage: String,
                decodable serverError: Decodable? = nil,
                error: Swift.Error? = nil) {
        self.error = error
        self.httpCode = httpCode
        self.errorMessage = errorMessage
        self.serverError = serverError
    }

    public init(_ error: Error) {
        if let envelope = error as? ErrorEnvelope {
            self = envelope
        } else {
            self.init(
                httpCode: 400,
                errorMessage: "Unknown Error",
                error: error
            )
        }
    }
}

extension ErrorEnvelope: Equatable {
    public static func == (lhs: ErrorEnvelope, rhs: ErrorEnvelope) -> Bool {
        return lhs.httpCode == rhs.httpCode &&
            lhs.errorMessage == rhs.errorMessage
    }
}

private extension Data {
    var rawString: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

extension ErrorEnvelope {
    internal static func couldNotConnectedToInternet(_ error: NSError) -> ErrorEnvelope {
        return ErrorEnvelope(
            httpCode: 400,
            errorMessage: "Device not connected to internet",
            error: error
        )
    }

    internal static let unauthorizedErrorEnvelope = ErrorEnvelope(
        httpCode: 401,
        errorMessage: "Unauthorized"
    )

    internal static let couldNotParseErrorEnvelope = ErrorEnvelope(
        httpCode: 400,
        errorMessage: ""
    )

    internal static let couldNotParseObjectJson = ErrorEnvelope(
        httpCode: 400,
        errorMessage: "Could not parse object Json"
    )

    internal static func couldNotDecodeJson(_ decodeError: DecodingError) -> ErrorEnvelope {
        return .init(
            httpCode: 400,
            errorMessage: "Could not parse object Json: \(decodeError.errorDescription ?? "")",
            error: decodeError
        )
    }
}
