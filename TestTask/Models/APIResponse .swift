import Foundation

struct Content: Codable {
    let id: Int
    let name: String
    let image: String?
}

struct APIResponse: Codable {
    let content: [Content]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}
