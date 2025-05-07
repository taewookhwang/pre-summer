import Foundation

class UserRepository {
    static let shared = UserRepository()
    
    // 의존성
    private let databaseManager = DatabaseManager.shared
    private let keychainManager = KeychainManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    
    // 키
    private let currentUserKey = "current_user"
    private let authTokenKey = "auth_token"
    
    private init() {}
    
    // 현재 사용자 저장
    func saveCurrentUser(_ user: AppUser) -> Bool {
        return databaseManager.save(user, forKey: currentUserKey)
    }
    
    // 현재 사용자 불러오기
    func getCurrentUser() -> AppUser? {
        return databaseManager.load(forKey: currentUserKey)
    }
    
    // 현재 사용자 삭제 (로그아웃)
    func clearCurrentUser() -> Bool {
        return databaseManager.delete(forKey: currentUserKey)
    }
    
    // 인증 토큰 저장
    func saveAuthToken(_ token: String) -> Bool {
        return keychainManager.saveToken(token, forKey: authTokenKey)
    }
    
    // 인증 토큰 불러오기
    func getAuthToken() -> String? {
        return keychainManager.getToken(forKey: authTokenKey)
    }
    
    // 인증 토큰 삭제 (로그아웃)
    func clearAuthToken() -> Bool {
        return keychainManager.deleteToken(forKey: authTokenKey)
    }
    
    // 사용자 로그인 상태 확인
    func isUserLoggedIn() -> Bool {
        return getAuthToken() != nil && getCurrentUser() != nil
    }
    
    // 사용자 프로필 업데이트
    func updateUserProfile(name: String? = nil, phone: String? = nil, address: String? = nil) -> Bool {
        guard var currentUser = getCurrentUser() else {
            return false
        }
        
        // 새로운 사용자 객체 생성 (AppUser 속성이 let이므로 수정불가)
        let updatedUser = AppUser(
            id: currentUser.id,
            email: currentUser.email,
            role: currentUser.role,
            name: name ?? currentUser.name,
            phone: phone ?? currentUser.phone,
            address: address ?? currentUser.address,
            createdAt: currentUser.createdAt
        )
        
        return saveCurrentUser(updatedUser)
    }
    
    // 로그아웃 (모든 사용자 데이터 삭제)
    func logout() -> Bool {
        let tokenCleared = clearAuthToken()
        let userCleared = clearCurrentUser()
        
        return tokenCleared && userCleared
    }
    
    // 테스트용 더미 사용자 생성
    func createDummyUser(role: String) -> AppUser {
        let userId = role == "technician" ? 2000 : (role == "admin" ? 1000 : 3000)
        
        return AppUser(
            id: userId,
            email: "\(role)@example.com",
            role: role,
            name: "Test \(role.capitalized)",
            phone: "010-1234-5678",
            address: "Seoul, Korea",
            createdAt: Date()
        )
    }
}