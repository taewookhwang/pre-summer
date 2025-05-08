import Foundation
import Network
import Alamofire

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
        completion: @escaping (Result<Any, APIError>) -> Void
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
            switch result {
            case .success(let registerResponse):
                // Use the strongly-typed result from the API
                let response = registerResponse as! AuthResponse
                
                // 토큰 저장
                _ = self.keychain.saveToken(response.token, forKey: "accessToken")
                _ = self.keychain.saveToken(response.refreshToken, forKey: "refreshToken")
                
                // 사용자 정보 저장
                _ = self.userRepository.saveCurrentUser(response.user.toDomain())
                
                // Return the raw response to match the protocol
                completion(.success(registerResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<Any, APIError>) -> Void) {
        authAPI.login(email: email, password: password) { result in
            switch result {
            case .success(let authResponse):
                // Use the strongly-typed result from the API
                let response = authResponse as! AuthResponse
                
                // 액세스 토큰 저장
                let tokenSaved = self.keychain.saveToken(response.token, forKey: "accessToken")
                if tokenSaved {
                    print("Access token saved successfully: \(String(response.token.prefix(10)))...")
                } else {
                    print("Failed to save access token")
                }
                
                // 리프레시 토큰 저장
                let refreshTokenSaved = self.keychain.saveToken(response.refreshToken, forKey: "refreshToken")
                if refreshTokenSaved {
                    print("Refresh token saved successfully: \(String(response.refreshToken.prefix(10)))...")
                } else {
                    print("Failed to save refresh token")
                }
                
                // 사용자 정보 저장
                _ = self.userRepository.saveCurrentUser(response.user.toDomain())
                
                // 토큰 검증
                if let savedToken = self.getAccessToken(), let savedRefreshToken = self.getRefreshToken() {
                    print("Tokens verified - both tokens successfully retrieved from keychain")
                } else {
                    print("⚠️ Warning: Could not retrieve saved tokens from keychain!")
                }
                
                // Return the raw response to match the protocol
                completion(.success(authResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: ((Result<Bool, APIError>) -> Void)? = nil) {
        // 토큰 삭제
        _ = keychain.deleteToken(forKey: "accessToken")
        _ = keychain.deleteToken(forKey: "refreshToken")
        
        // 사용자 정보 삭제
        _ = userRepository.clearCurrentUser()
        
        // 필요한 경우 서버에 로그아웃 요청을 보낼 수 있음
        // authAPI.logout { result in
        //     completion?(result)
        // }
        
        // 지금은 항상 성공으로 처리
        if let completion = completion {
            DispatchQueue.main.async {
                completion(.success(true))
            }
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
    
    func refreshToken(completion: @escaping (Result<Any, APIError>) -> Void) {
        refreshTokenWithStringResult { result in
            switch result {
            case .success(let token):
                // Create a simple RefreshTokenResponse to return for backward compatibility
                let response = RefreshTokenResponseSimple(success: true, token: token)
                completion(.success(response))
            case .failure(let error):
                if let apiError = error as? APIError {
                    completion(.failure(apiError))
                } else {
                    completion(.failure(.customError(message: error.localizedDescription)))
                }
            }
        }
    }
    
    func refreshTokenWithStringResult(completion: @escaping (Result<String, Error>) -> Void) {
        // 저장된 리프레시 토큰 가져오기
        guard let refreshToken = keychain.getToken(forKey: "refreshToken") else {
            print("리프레시 토큰이 없습니다")
            completion(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "리프레시 토큰이 없습니다"])))
            return
        }
        
        print("토큰 갱신 시도 중: \(refreshToken.prefix(10))...")
        
        // 요청 준비 - 백엔드 설정에 맞는 정확한 URL 사용
        // APIGateway의 baseURL 사용
        #if DEBUG
        let baseURL = "http://localhost:3000"
        #else
        let baseURL = "https://api.yourproductionserver.com"
        #endif
        
        // 백엔드 게이트웨이 설정에 맞게 URL 경로 조정
        // 1. Auth 서비스는 /api/refresh 경로를 기대함
        // 2. Gateway는 /api/auth/* 요청을 받아서 Auth 서비스로 프록시할 때 경로를 변환함
        // 3. 앱에서는 /api/auth/refresh로 요청 → Gateway가 /api/refresh로 변환하여 Auth 서비스로 전달
        let url = "\(baseURL)/api/auth/refresh"
        
        // 참고: 백엔드 코드를 확인한 결과, Auth 서비스가 /refresh가 아닌 /api/refresh 경로를 기대한다면
        // 게이트웨이 설정도 함께 수정되어야 합니다. 게이트웨이가 /api/auth/refresh를 /api/refresh로 
        // 변환하도록 설정되어야 합니다.
        let parameters: [String: Any] = ["refresh_token": refreshToken]
        
        // API 요청
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: RefreshTokenResponseSimple.self) { response in
                switch response.result {
                case .success(let data):
                    print("토큰 갱신 성공")
                    // 새 액세스 토큰 저장
                    _ = self.keychain.saveToken(data.token, forKey: "accessToken")
                    completion(.success(data.token))
                case .failure(let error):
                    print("토큰 갱신 실패: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // 간소화된 RefreshTokenResponse 구조체
    struct RefreshTokenResponseSimple: Decodable {
        let success: Bool
        let token: String
    }
}

