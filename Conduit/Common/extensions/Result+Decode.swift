import Foundation

extension Result where Success == (Data, HTTPURLResponse), Failure == ErrorEnvelope {
    func decoded<T: Decodable>() -> Result<T, Failure> {
        return flatMap { (arg) -> Result<T, ErrorEnvelope> in

            let (data, _) = arg
            return data.decode().mapError {
                guard let error = $0 as? DecodingError else {
                    return ErrorEnvelope($0)
                }
                return ErrorEnvelope.couldNotDecodeJson(error)
            }
        }
    }
}
