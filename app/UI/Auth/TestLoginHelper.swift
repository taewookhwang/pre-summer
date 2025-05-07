import UIKit

// 테스트 로그인 헬퍼 클래스
// 앱 디버깅 과정에서 사용자 로그인 과정을 단순화하기 위한 헬퍼 클래스
class TestLoginHelper {
    static let shared = TestLoginHelper()
    
    private let authService = AuthService.shared
    private let userRepository = UserRepository.shared
    
    private init() {}
    
    // 테스트 사용자 계정 데이터
    struct TestUserData {
        let email: String
        let password: String
        let role: String
        let name: String
        let id: Int
    }
    
    // 테스트 사용자 계정 목록
    private let testUsers: [TestUserData] = [
        TestUserData(email: "consumer@example.com", password: "test123", role: "consumer", name: "테스트 고객", id: 3001),
        TestUserData(email: "technician@example.com", password: "test123", role: "technician", name: "테스트 기사", id: 2001),
        TestUserData(email: "admin@example.com", password: "test123", role: "admin", name: "테스트 관리자", id: 1001)
    ]
    
    // 테스트 사용자 빠른 로그인 기능 (역할별)
    func quickLogin(role: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        guard let user = testUsers.first(where: { $0.role == role }) else {
            completion(.failure(NSError(domain: "TestLoginHelper", code: 404, userInfo: [NSLocalizedDescriptionKey: "해당 역할의 테스트 계정을 찾을 수 없습니다."])))
            return
        }
        
        // 인증 토큰 생성 및 사용자 정보 저장
        createTestSession(for: user, completion: completion)
    }
    
    // 테스트 사용자 세션 생성 (토큰 및 사용자 정보 저장)
    private func createTestSession(for userData: TestUserData, completion: @escaping (Result<AppUser, Error>) -> Void) {
        // 가상 토큰 생성
        let token = "test_token_\(userData.role)_\(Int(Date().timeIntervalSince1970))"
        let refreshToken = "test_refresh_token_\(userData.role)_\(Int(Date().timeIntervalSince1970))"
        
        // 키체인에 토큰 저장
        _ = KeychainManager.shared.saveToken(token, forKey: "accessToken")
        _ = KeychainManager.shared.saveToken(refreshToken, forKey: "refreshToken")
        
        // 테스트 사용자 객체 생성
        let user = AppUser(
            id: userData.id,
            email: userData.email,
            role: userData.role,
            name: userData.name,
            phone: "010-1234-5678",
            address: "서울시 강남구",
            createdAt: Date()
        )
        
        // 사용자 저장소에 저장
        if userRepository.saveCurrentUser(user) {
            completion(.success(user))
        } else {
            completion(.failure(NSError(domain: "TestLoginHelper", code: 500, userInfo: [NSLocalizedDescriptionKey: "테스트 사용자 정보 저장에 실패했습니다."])))
        }
    }
    
    // 테스트 버튼 생성 함수
    func createTestLoginButtons(on viewController: UIViewController, completion: @escaping () -> Void) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "테스트 계정으로 로그인"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        stackView.addArrangedSubview(titleLabel)
        
        let roles = ["consumer", "technician", "admin"]
        let roleLabels = ["고객", "기사", "관리자"]
        
        for (index, role) in roles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle("\(roleLabels[index]) 계정으로 로그인", for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 5
            button.tag = index
            button.addAction(UIAction { _ in
                self.quickLogin(role: role) { result in
                    switch result {
                    case .success:
                        completion()
                    case .failure(let error):
                        let alert = UIAlertController(
                            title: "로그인 실패",
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        viewController.present(alert, animated: true)
                    }
                }
            }, for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
}