
import Foundation

private let defaultSessionError = NSError(domain: "dev.amadeu.Conduit", code: 1, userInfo: nil)

extension URLSession {
    func load(_ request: URLRequest,
              _ completionHandler: @escaping (Result<(Data, HTTPURLResponse), ErrorEnvelope>) -> Void) {
        dataTask(request) { result in
            DispatchQueue.main.async { (transformDataTask >>> completionHandler)(result) }
        }
    }

    func dataTask(
        _ request: URLRequest,
        _ completionHandler: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>
        ) -> Void) {

        dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                let data = data else {
                    completionHandler(.failure(error ?? defaultSessionError))
                    return
            }

            completionHandler(.success((data, response)))
            }.resume()
    }
}

private func transformDataTask(_ result: Result<(Data, HTTPURLResponse), Swift.Error>)
    -> Result<(Data, HTTPURLResponse), ErrorEnvelope> {
        return result
            .mapError { error in
                if let error = error as NSError?,
                    error.domain == NSURLErrorDomain,
                    error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut {
                    return ErrorEnvelope.couldNotConnectedToInternet(error)
                }

                return ErrorEnvelope.couldNotParseErrorEnvelope
            }
            .flatMap { (data, response) -> Result<(Data, HTTPURLResponse), ErrorEnvelope> in
                guard (200..<300).contains(response.statusCode) else {
                    let serverError = data.decode() as ServerError?
                    return .failure(ErrorEnvelope(decodable: serverError, data: data, urlResponse: response))
                }
                return .success((data, response))
        }
}
