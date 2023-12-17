import Foundation

// URL http method type.
enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var port: Int? { get }
    var parameters: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    var authToken: String? { get }
    var body: Data { get }
}

enum APIModel: APIEndpoint, Equatable {
    case downloadData(page: Int)
    case uploadData
    case downloadImage(id: Int)
    
    var baseURL: String {
        "junior.balinasoft.com"
    }

    var path: String {
        switch self {
        case .downloadData:
            return "/api/v2/photo/type"
        case .uploadData:
            return "/api/v2/photo"
        case .downloadImage(id: let id):
            return "/images/type/\(id).jpg"
        }
    }

    var port: Int? {
        nil
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .downloadData(let page):
            return [
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .uploadData:
            return []
        case .downloadImage(id: let id):
            return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .downloadData:
            return .get
        case .uploadData:
            return .post
        case .downloadImage(id: let id):
            return .get
        }
    }

    var authToken: String? {
        nil
    }
    
    var body: Data {
        switch self {
        case .downloadData:
            return Data()
        case .uploadData:
            return Data() // TODO: set data to upload
        case .downloadImage:
            return Data()
        }
    }
}
