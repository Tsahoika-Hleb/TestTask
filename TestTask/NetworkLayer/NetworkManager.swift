import Foundation

final class NetworkManager {
    private let urlRequestBuilder: URLRequestBuilding
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared, urlRequestBuilder: URLRequestBuilding = URLRequestBuilder()) {
        self.urlRequestBuilder = urlRequestBuilder
        self.urlSession = urlSession
    }

    func request<T: Decodable>(config: APIModel,
                               responseHandler: ResponseHandler,
                               isApiResponse: Bool = true,
                               retryCount: Int = 0,
                               completion: @escaping (Result<T, Error>) -> Void) {
        performRequest(config: config,
                       responseHandler: responseHandler,
                       isApiResponse: isApiResponse,
                       retryCount: retryCount,
                       completion: completion)
    }

    private func performRequest<T: Decodable>(config: APIModel,
                                              responseHandler: ResponseHandler,
                                              isApiResponse: Bool,
                                              retryCount: Int,
                                              completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlRequest = urlRequestBuilder.buildURLRequest(config: config) else {
            completion(.failure(AppError.otherError(text: "URL creation error")))
            return
        }

        let dataTask = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            responseHandler.handle(data: data,
                                   response: response,
                                   error: error,
                                   isApiResponse: isApiResponse) { (result: Result<T, Error>) in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    debugPrint(error)
                    self?.handleRetry(config: config,
                                      responseHandler: responseHandler,
                                      isApiResponse: isApiResponse,
                                      retryCount: retryCount,
                                      completion: completion)
                }
            }
        }

        dataTask.resume()
    }

    private func handleRetry<T: Decodable>(config: APIModel,
                                           responseHandler: ResponseHandler,
                                           isApiResponse: Bool,
                                           retryCount: Int,
                                           completion: @escaping (Result<T, Error>) -> Void) {
        if retryCount > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.performRequest(config: config,
                                     responseHandler: responseHandler,
                                     isApiResponse: isApiResponse,
                                     retryCount: retryCount - 1,
                                     completion: completion)
            }
        } else {
            completion(.failure(AppError.retryFailed))
        }
    }
}

enum AppError: Error {
    case retryFailed
    case otherError(text: String)
    case decodingError
}


// TODO: - сделать обертку с complition через async await
