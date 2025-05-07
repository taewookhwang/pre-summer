import Foundation

class LoginViewModel {
    // Enum representing result state
    enum LoginState {
        case idle
        case loading
        case success(user: AppUserDTO)
        case failure(error: Error)
    }
    
    // State change callback
    var onStateChanged: ((LoginState) -> Void)?
    
    // Current state
    private(set) var state: LoginState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    private let authService = AuthService.shared
    
    // Login action
    func login(email: String, password: String) {
        // Input validation
        guard isValidEmail(email), !password.isEmpty else {
            state = .failure(error: NSError(domain: "com.homecleaningapp", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email or empty password"]))
            return
        }
        
        // Change to loading state
        state = .loading
        
        // Call authentication service
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
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}