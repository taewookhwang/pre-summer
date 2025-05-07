import Foundation

protocol AuthServiceProtocol {
    // 사용자 등록
    func register(
        email: String,
        password: String,
        role: String,
        name: String?,
        phone: String?,
        address: String?,
        completion: @escaping (Result<AuthResponse, APIError>) -> Void
    )
    
    // 로그인
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthResponse, APIError>) -> Void
    )
    
    // 로그아웃
    func logout(completion: @escaping (Result<Bool, APIError>) -> Void)
    
    // 비밀번호 재설정
    func resetPassword(email: String, completion: @escaping (Result<Bool, APIError>) -> Void)
    
    // 액세스 토큰 가져오기
    func getAccessToken() -> String?
    
    // 리프레시 토큰 가져오기
    func getRefreshToken() -> String?
    
    // 로그인 상태 확인
    func isLoggedIn() -> Bool
    
    // 현재 사용자 역할 가져오기
    func getCurrentUserRole() -> String?
    
    // 현재 사용자 정보 가져오기
    func getCurrentUser(completion: @escaping (Result<AppUser, APIError>) -> Void)
    
    // 토큰 갱신
    func refreshToken(completion: @escaping (Result<AuthResponse, APIError>) -> Void)
}