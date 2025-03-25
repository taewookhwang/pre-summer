import Foundation

class LoginViewModel {
    // 결과 상태를 나타내는 enum
    enum LoginState {
        case idle
        case loading
        case success(user: UserDTO)
        case failure(error: Error)
    }
    
    // 상태 변경 콜백
    var onStateChanged: ((LoginState) -> Void)?
    
    // 현재 상태
    private(set) var state: LoginState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    private let authService = AuthService.shared
    
    // 로그인 액션
    func login(email: String, password: String) {
        // 입력 유효성 검사
        guard isValidEmail(email), !password.isEmpty else {
            state = .failure(error: NSError(domain: "com.homecleaningapp", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email or empty password"]))
            return
        }
        
        // 로딩 상태로 변경
        state = .loading
        
        // 인증 서비스 호출
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.state = .success(user: response.user)
                case .failure(let error):
                    self?.state = .failure(error: error)
                }
            }
        }
    }
    
    // 이메일 유효성 검사
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
