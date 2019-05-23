import Foundation

final class ServerClient {
    public var serverConfig: ServerConfig

    init(with config: ServerConfig) {
        self.serverConfig = config
    }
}
