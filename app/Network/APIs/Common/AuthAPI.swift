import Alamofire

struct AuthAPI {
    static let shared = AuthAPI()
    private let gateway = APIGateway.shared
    
    // 회원가입
    func register(userData: [String: Any], completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        gateway.request("/auth/register", method: .post, parameters: userData, headers: headers, completion: completion)
    }
    
    // 로그인
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "password": password]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        gateway.request("/auth/login", method: .post, parameters: parameters, headers: headers, completion: completion)
    }
}

// DTO 정의
struct AuthResponse: Decodable {
    let success: Bool
    let token: String
    let refreshToken: String
    let user: UserDTO
}

struct UserDTO: Decodable {
    let id: Int
    let email: String
    let role: String
    let name: String?
}
