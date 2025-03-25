import UIKit

class SignupVC: UIViewController {
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let nameTextField = UITextField()
    private let rolePicker = UIPickerView()
    private let signupButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var viewModel: SignupViewModel!
    weak var coordinator: AuthCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        rolePicker.delegate = self
        rolePicker.dataSource = self
    }
    
    private func setupUI() {
        title = "Sign Up"
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
        
        nameTextField.placeholder = "Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        rolePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rolePicker)
        
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signupButton)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalToConstant: 300),
            
            rolePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rolePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            rolePicker.widthAnchor.constraint(equalToConstant: 300),
            rolePicker.heightAnchor.constraint(equalToConstant: 100),
            
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.topAnchor.constraint(equalTo: rolePicker.bottomAnchor, constant: 20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            switch state {
            case .idle:
                self?.loadingIndicator.stopAnimating()
                self?.signupButton.isEnabled = true
                
            case .loading:
                self?.loadingIndicator.startAnimating()
                self?.signupButton.isEnabled = false
                
            case .success(let user):
                self?.loadingIndicator.stopAnimating()
                self?.signupButton.isEnabled = true
                self?.coordinator?.showHome(for: user)
                
            case .failure(let error):
                self?.loadingIndicator.stopAnimating()
                self?.signupButton.isEnabled = true
                self?.showError(error)
            }
        }
    }
    
    @objc private func signupTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text else { return }
        
        let selectedRole = viewModel.roles[rolePicker.selectedRow(inComponent: 0)]
        viewModel.signup(email: email, password: password, name: name, role: selectedRole)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SignupVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.roles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.roles[row]
    }
}
