import UIKit

class LoginVC: UIViewController {
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signupButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var viewModel: LoginViewModel!
    weak var coordinator: AuthCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupTestLoginButtons()
    }
    
    private func setupUI() {
        title = "Login"
        view.backgroundColor = .white
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        signupButton.setTitle("Don't have an account? Sign Up", for: .normal)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signupButton)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - 개발용 테스트 로그인 버튼 설정
    private func setupTestLoginButtons() {
        #if DEBUG
        // 먼저 현재 저장된 토큰 검증
        validateTestTokens()
        
        // 테스트 로그인 버튼 추가
        TestLoginHelper.shared.createTestLoginButtons(on: self) { [weak self] in
            guard let self = self else { return }
            // 로그인 성공 후 처리
            self.coordinator?.showHome(for: UserDTO(
                id: UserRepository.shared.getCurrentUser()?.id ?? 0,
                email: UserRepository.shared.getCurrentUser()?.email ?? "",
                role: UserRepository.shared.getCurrentUser()?.role ?? "consumer",
                name: UserRepository.shared.getCurrentUser()?.name,
                phone: UserRepository.shared.getCurrentUser()?.phone,
                address: UserRepository.shared.getCurrentUser()?.address,
                createdAt: nil
            ))
        }
        #endif
    }
    
    // 저장된 테스트 토큰 검증하고 백엔드 인증 미들웨어 요구사항에 맞는지 확인
    private func validateTestTokens() {
        #if DEBUG
        let validation = TestLoginHelper.shared.validateStoredTestTokens()
        if !validation.isValid {
            // 안내 메시지 표시
            let alert = UIAlertController(
                title: "토큰 형식 변경 안내",
                message: "백엔드 인증 미들웨어가 업데이트되어 토큰 형식이 변경되었습니다.\n\n\(validation.message)\n\n테스트 로그인 버튼을 눌러 새 형식으로 다시 로그인하세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            // 다음 runloop에서 alert을 표시하여 화면 로딩 이후에 표시되도록 함
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true)
            }
        }
        #endif
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            switch state {
            case .idle:
                self?.loadingIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
                
            case .loading:
                self?.loadingIndicator.startAnimating()
                self?.loginButton.isEnabled = false
                
            case .success(let user):
                self?.loadingIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
                self?.coordinator?.showHome(for: user)
                
            case .failure(let error):
                self?.loadingIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
                self?.showError(error)
            }
        }
    }
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.login(email: email, password: password)
    }
    
    @objc private func signupTapped() {
        coordinator?.showSignup()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
