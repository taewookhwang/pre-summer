import Foundation

// Prefix the User type to avoid ambiguity with system User types
struct AppUser: Codable {
    let id: Int
    let email: String
    let role: String
    let name: String?
    let phone: String?
    let address: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, email, role, name, phone, address
        case createdAt = "created_at"
    }
    
    // Explicitly implement Decodable initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        role = try container.decode(String.self, forKey: .role)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
    
    // Explicitly implement Encodable function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
    
    // Standard initializer with default values for optional parameters
    init(id: Int, email: String, role: String, name: String? = nil, phone: String? = nil, address: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.phone = phone
        self.address = address
        self.createdAt = createdAt
    }
}

// No typealias to avoid name conflict
// The 'User' type may already exist in the system, so we use 'AppUser' instead