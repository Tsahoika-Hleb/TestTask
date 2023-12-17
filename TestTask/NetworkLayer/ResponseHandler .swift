import Foundation

protocol ResponseHandler {
    func handle<T: Decodable>(data: Data?,
                              response: URLResponse?,
                              error: Error?,
                              isApiResponse: Bool,
                              completion: @escaping (Result<T, Error>) -> Void)
}

struct DefaultResponseHandler: ResponseHandler {
    func handle<T: Decodable>(data: Data?,
                              response: URLResponse?,
                              error: Error?,
                              isApiResponse: Bool = true,
                              completion: @escaping (Result<T, Error>) -> Void) {
        if let error = error {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        
        guard let response = response as? HTTPURLResponse, let data = data else { return }
#if !DEBUG
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
#endif
        if response.statusCode == 200 {
            DispatchQueue.main.async {
                if let dataObject: T = decodeData(data, isApiResponse: isApiResponse) {
                    completion(.success(dataObject))
                } else {
                    completion(.failure(AppError.decodingError))
                }
            }
        } else {
            let error = NSError(domain: "com.combient",
                                code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Failed"])
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }

    private func decodeData<T: Decodable>(_ data: Data, isApiResponse: Bool) -> T? {
        if isApiResponse {
            return try? JSONDecoder().decode(T.self, from: data)
        } else {
            if T.self == String.self {
                if let decodedString = String(data: data, encoding: .utf8) {
                    return decodedString as? T
                }
            } else {
                if T.self == Data.self {
                    return data as? T
                } else {
                    return try? JSONDecoder().decode(T.self, from: data)
                }
            }
        }
        return nil
    }
}

