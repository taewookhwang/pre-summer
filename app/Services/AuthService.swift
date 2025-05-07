import Foundation

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let authAPI = AuthAPI.shared
    private let keychain = KeychainManager.shared
    private let userRepository = UserRepository.shared
    
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
                
                // 사용자 정보 저장
                _ = self.userRepository.saveCurrentUser(response.user.toDomain())
            }
            completion(result)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        authAPI.login(email: email, password: password) { result in
            if case .success(let response) = result {
                _ = self.keychain.saveToken(response.token, forKey: "accessToken")
                _ = self.keychain.saveToken(response.refreshToken, forKey: "refreshToken")
                
                // 사용자 정보 저장
                _ = self.userRepository.saveCurrentUser(response.user.toDomain())
            }
            completion(result)
        }
    }
    
    func logout(completion: @escaping (Result<Bool, APIError>) -> Void) {
        // 토큰 삭제
        _ = keychain.deleteToken(forKey: "accessToken")
        _ = keychain.deleteToken(forKey: "refreshToken")
        
        // 사용자 정보 삭제
        _ = userRepository.clearCurrentUser()
        
        // 필요한 경우 서버에 로그아웃 요청을 보낼 수 있음
        // authAPI.logout { result in
        //     completion(result)
        // }
        
        // 지금은 항상 성공으로 처리
        DispatchQueue.main.async {
            completion(.success(true))
        }
    }
    
    func getAccessToken() -> String? {
        keychain.getToken(forKey: "accessToken")
    }
    
    func getRefreshToken() -> String? {
        keychain.getToken(forKey: "refreshToken")
    }
    
    // MARK: - 추가 구현 메서드
    
    func resetPassword(email: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        // 백엔드 API 직접 호출 또는 아직 구현되지 않은 기능이므로 임시 구현
        DispatchQueue.main.async {
            completion(.success(true))
        }
    }
    
    func isLoggedIn() -> Bool {
        return getAccessToken() != nil && userRepository.getCurrentUser() != nil
    }
    
    func getCurrentUserRole() -> String? {
        return userRepository.getCurrentUser()?.role
    }
    
    func getCurrentUser(completion: @escaping (Result<AppUser, APIError>) -> Void) {
        if let currentUser = userRepository.getCurrentUser() {
            DispatchQueue.main.async {
                completion(.success(currentUser))
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(.customError(message: "사용자 정보를 찾을 수 없습니다.")))
            }
        }
    }
    
    func refreshToken(completion: @escaping (Result<AuthResponse, APIError>) -> Void) {
        // 토큰 갱신 로직
        // 아직 백엔드 API가 구현되지 않았다면 임시로 구현
        // 실제 구현에서는 리프레시 토큰으로 새로운 액세스 토큰을 요청
        
        // 임시 구현: 성공 상태로 가정하고 임의의 응답 생성
        DispatchQueue.main.async {
            if let currentUser = self.userRepository.getCurrentUser(),
               let token = self.getAccessToken(),
               let refreshToken = self.getRefreshToken() {
                
                // 현재 사용자 정보로 DTO 생성
                let userDTO = AppUserDTO(
                    id: currentUser.id,
                    email: currentUser.email,
                    role: currentUser.role,
                    name: currentUser.name,
                    phone: currentUser.phone,
                    address: currentUser.address,
                    createdAt: nil  // 날짜 정보는 없으므로 nil
                )
                
                // 임시 인증 응답 생성
                let authResponse = AuthResponse(
                    success: true,
                    token: token,
                    refreshToken: refreshToken,
                    user: userDTO,
                    expiresIn: 3600,
                    tokenType: "Bearer"
                )
                
                completion(.success(authResponse))
            } else {
                completion(.failure(.unauthorized))
            }
        }
    }
}

