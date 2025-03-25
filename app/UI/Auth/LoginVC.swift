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
