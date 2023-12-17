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
    // var body: Data { get }
    func getBody(boundary: String) -> Data
}

enum APIModel: APIEndpoint {
    
    case downloadData(page: Int)
    case uploadData(model: APIRequestBody)
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
        case .downloadImage:
            return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .downloadData:
            return .get
        case .uploadData:
            return .post
        case .downloadImage:
            return .get
        }
    }

    var authToken: String? {
        nil
    }
    
    func getBody(boundary: String) -> Data {
        switch self {
        case .uploadData(let model):
            var httpBody = Data()

            func append(_ string: String) {
                if let data = string.data(using: .utf8) {
                    httpBody.append(data)
                }
            }

            func appendLineBreak() {
                append("\r\n")
            }

            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"name\"\r\n\r\n\(model.name)\r\n")

            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n\(model.typeId)\r\n")

            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n")
            append("Content-Type: image/jpeg\r\n\r\n")

            httpBody.append(model.photo)

            appendLineBreak()
            append("--\(boundary)--\r\n")

            return httpBody
        default: return Data()
        }
    }
}
