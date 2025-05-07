import Foundation
import Network

struct AuthAPI {
    static let shared = AuthAPI()
    private let gateway = APIGateway.shared
    
    // Register new user
    func register(userData: [String: Any], completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        gateway.request("/auth/register", method: .post, parameters: userData, headers: nil, completion: completion)
    }
    
    // Login with email and password
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "password": password]
        gateway.request("/auth/login", method: .post, parameters: parameters, headers: nil, completion: completion)
    }
}

// DTO definitions
struct AuthResponse: Decodable {
    let success: Bool
    let token: String
    let refreshToken: String
    let user: AppUserDTO
    let expiresIn: Int?
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case success, token, user
        case refreshToken = "refresh_token"  // snake_case 필드명 매핑
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
