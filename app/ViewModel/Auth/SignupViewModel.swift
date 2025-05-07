import Foundation

class SignupViewModel {
    // Enum representing result state
    enum SignupState {
        case idle
        case loading
        case success(user: AppUserDTO)
        case failure(error: Error)
    }
    
    // State change callback
    var onStateChanged: ((SignupState) -> Void)?
    
    // Current state
    private(set) var state: SignupState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    // Role list
    let roles = ["consumer", "technician"]
    
    private let authService = AuthService.shared
    
    // Signup action
    func signup(email: String, password: String, name: String, role: String) {
        // Input validation
        guard isValidEmail(email), !password.isEmpty, !name.isEmpty else {
            state = .failure(error: NSError(domain: "com.homecleaningapp", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid input data"]))
            return
        }
        
        // Change to loading state
        state = .loading
        
        // Call authentication service
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
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}