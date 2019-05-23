import Foundation

public struct ServerConfig {
    public let userSession: Session?
    let baseUrl: URL
    let institutionToken: String
    let environment: Environment

    public init(baseUrl: URL,
                institutionToken: String,
                environment: Environment,
                userSession: Session? = nil) {
        self.baseUrl = baseUrl
        self.environment = environment
        self.institutionToken = institutionToken
        self.userSession = userSession
    }

    public func copy(with session: Session) -> ServerConfig {
        return ServerConfig(
            baseUrl: self.baseUrl,
            institutionToken: self.institutionToken,
            environment: self.environment,
            userSession: session
        )
    }
}

public enum Environment: String {
    case production = "Production"
    case staging = "Staging"
    case local = "Local"
}

extension ServerConfig: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """

        baseUrl = \(baseUrl)
        environment = \(environment)
        institutionToken = \(institutionToken)
        userSession = \(String(describing: userSession))

        """
    }
}
