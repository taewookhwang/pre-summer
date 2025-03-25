import Foundation

class SignupViewModel {
    // 결과 상태를 나타내는 enum
    enum SignupState {
        case idle
        case loading
        case success(user: UserDTO)
        case failure(error: Error)
    }
    
    // 상태 변경 콜백
    var onStateChanged: ((SignupState) -> Void)?
    
    // 현재 상태
    private(set) var state: SignupState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    // 역할 목록
    let roles = ["consumer", "technician"]
    
    private let authService = AuthService.shared
    
    // 회원가입 액션
    func signup(email: String, password: String, name: String, role: String) {
        // 입력 유효성 검사
        guard isValidEmail(email), !password.isEmpty, !name.isEmpty else {
            state = .failure(error: NSError(domain: "com.homecleaningapp", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid input data"]))
            return
        }
        
        // 로딩 상태로 변경
        state = .loading
        
        // 인증 서비스 호출
        authService.register(email: email, password: password, role: role, name: name, phone: nil, address: nil) { [weak self] result in
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
