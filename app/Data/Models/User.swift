import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let role: String
    let name: String?
    let phone: String?
    let address: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, role, name, phone, address
        case createdAt = "created_at"
    }
}
