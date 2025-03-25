import Foundation

class AuthService {
    static let shared = AuthService()
    private let authAPI = AuthAPI.shared
    private let keychain = KeychainManager.shared
    
    private init() {}
    
    func register(
        email: String,
        password: String,
        role: String,
        name: String?,
        phone: String?,
        address: String?,
        completion: @escaping (Result<AuthResponse, APIError>) -> Void
    ) {
        let userData: [String: Any] = [
            "email": email,
            "password": password,
            "role": role,
            "name": name ?? "",
            "phone": phone ?? "",
            "address": address ?? ""
        ]
        authAPI.register(userData: userData) { result in
            if case .success(let response) = result {
                _ = self.keychain.saveToken(response.token, forKey: "accessToken")
                _ = self.keychain.saveToken(response.refreshToken, forKey: "refreshToken")
            }
            completion(result)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        authAPI.login(email: email, password: password) { result in
            if case .success(let response) = result {
                _ = self.keychain.saveToken(response.token, forKey: "accessToken")
                _ = self.keychain.saveToken(response.refreshToken, forKey: "refreshToken")
            }
            completion(result)
        }
    }
    
    func getAccessToken() -> String? {
        keychain.getToken(forKey: "accessToken")
    }
    
    func getRefreshToken() -> String? {
        keychain.getToken(forKey: "refreshToken")
    }
}
