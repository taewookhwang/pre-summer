import Foundation

// Data Transfer Object for User model
struct AppUserDTO: Codable {
    let id: Int
    let email: String
    let role: String
    let name: String?
    let phone: String?
    let address: String?
    let createdAt: String?  // Date에서 String으로 변경
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
        case name
        case phone
        case address
        case createdAt = "created_at"
    }
    
    // Custom initializer
    init(id: Int, email: String, role: String, name: String? = nil, phone: String? = nil, address: String? = nil, createdAt: String? = nil) {  // Date에서 String으로 변경
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.phone = phone
        self.address = address
        self.createdAt = createdAt
    }
    
    // Conversion to domain model
    func toDomain() -> AppUser {
        // String 날짜를 Date로 변환
        var createdAtDate: Date? = nil
        if let dateString = createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            createdAtDate = dateFormatter.date(from: dateString)
            
            // 첫 번째 포맷으로 변환 실패시 다른 포맷 시도
            if createdAtDate == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                createdAtDate = dateFormatter.date(from: dateString)
            }
        }
        
        return AppUser(
            id: id,
            email: email,
            role: role,
            name: name,
            phone: phone,
            address: address,
            createdAt: createdAtDate
        )
    }
}

// For backward compatibility - alias to AppUserDTO
typealias UserDTO = AppUserDTO
