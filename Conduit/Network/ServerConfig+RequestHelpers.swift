
import Foundation

private let sessionConfig = URLSessionConfiguration.default
private let session: URLSession = URLSession(configuration: sessionConfig)

// swiftlint:disable opening_brace
extension ServerConfig {
    private var defaultHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["User-Agent"] = userAgent
        headers["Authorization"] = self.userSession?.token
        return headers
    }

    func request<T: Decodable>(_ route: Route) -> Task<T, ErrorEnvelope> {
        let properties = route.requestProperties

        guard let URL = URL(string: properties.path, relativeTo: self.baseUrl) else {
            fatalError(
                "URL(string: \(properties.path), relativeToURL: \(self.baseUrl)) == nil"
            )
        }

        return Task { controller in
            session.load(
                self.preparedRequest(forURL: URL, properties.method, properties.body),
                { controller.resolve($0.decoded()) }
            )
        }
    }

    func request(_ route: Route) -> Task<Void, ErrorEnvelope> {
        let properties = route.requestProperties

        guard let URL = URL(string: properties.path, relativeTo: self.baseUrl) else {
            fatalError(
                "URL(string: \(properties.path), relativeToURL: \(self.baseUrl)) == nil"
            )
        }

        return Task { controller in
            session.load(
                self.preparedRequest(forURL: URL, properties.method, properties.body),
                { controller.resolve($0.map { _ in () }) }
            )
        }
    }

    func request(_ route: Route) -> Task<String, ErrorEnvelope> {
        let properties = route.requestProperties

        guard let URL = URL(string: properties.path, relativeTo: self.baseUrl) else {
            fatalError(
                "URL(string: \(properties.path), relativeToURL: \(self.baseUrl)) == nil"
            )
        }

        return Task { controller in
            session.load(
                self.preparedRequest(forURL: URL, properties.method, properties.body),
                { controller.resolve($0.map { String(data: $0.0, encoding: .utf8) ?? "" }) }
            )
        }
    }

    public func preparedRequest(
        forURL url: URL,
        _ method: Method = .get,
        _ body: Encodable? = nil
        ) -> URLRequest {

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            return self.preparedRequest(forRequest: request, body: body)
    }

    public func preparedRequest(
        forRequest originalRequest: URLRequest,
        body: Encodable? = nil
        ) -> URLRequest {

        var request = originalRequest
        guard let URL = request.url else {
            return originalRequest
        }

        guard let components = URLComponents(url: URL, resolvingAgainstBaseURL: false) else {
            fatalError("URLComponents(url: \(URL) resolvingAgainstBaseURL: false)")
        }

        var headers = self.defaultHeaders
        let method = request.httpMethod?.uppercased()

        if method == .some("POST") || method == .some("PUT") {
            if request.httpBody == nil {
                headers["Content-Type"] = "application/json; charset=utf-8"
                request.httpBody = body?.encode()
            }
        }

        request.url = components.url

        let currentHeaders = request.allHTTPHeaderFields ?? [:]
        request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(headers)

        return request
    }
}
