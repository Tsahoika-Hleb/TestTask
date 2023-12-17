import Foundation

struct APIRequestBody: Codable {
    var name: String = "Tsahoika Hleb Srgeevich"
    let photo: Data
    let typeId: Int
}
