import Foundation

protocol URLRequestBuilding {
    func buildURLRequest(config: APIModel) -> URLRequest?
}

final class URLRequestBuilder: URLRequestBuilding {
    func buildURLRequest(config: APIModel) -> URLRequest? {
        let components = buildURL(config: config)
        guard let url = components.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = config.method.rawValue
        
        switch config {
        case .downloadData, .downloadImage:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .uploadData:
            let boundary = UUID().uuidString
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = config.getBody(boundary: boundary)
        }
        
        return urlRequest
    }
    
    private func buildURL(config: APIModel) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = config.baseURL
        components.path = config.path
        components.port = config.port
        if !config.parameters.isEmpty { components.queryItems = config.parameters }
        return components
    }
}
