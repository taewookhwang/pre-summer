import UIKit

class AuthCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    func showLogin() {
        let loginVC = LoginVC()
        loginVC.viewModel = LoginViewModel()
        loginVC.coordinator = self
        navigationController.setViewControllers([loginVC], animated: true)
    }
    
    func showSignup() {
        let signupVC = SignupVC()
        signupVC.viewModel = SignupViewModel()
        signupVC.coordinator = self
        navigationController.pushViewController(signupVC, animated: true)
    }
    
    // Method to display a notification after successful registration
    func showRegistrationSuccess() {
        // Display registration success notification
        let alert = UIAlertController(
            title: "Registration Success",
            message: "Your account has been successfully created. Going to the login screen.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Go to login screen
            self?.showLogin()
        })
        
        // Display notification on the currently visible screen
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    
    // Navigate to the appropriate home screen based on user role after successful login
    func showHome(for user: UserDTO) {
        switch user.role {
        case "consumer":
            showConsumerHome()
        case "technician":
            showTechnicianHome()
        case "admin":
            showAdminHome()
        default:
            showConsumerHome() // Default
        }
    }

    
    func showConsumerHome() {
        let consumerCoordinator = ConsumerCoordinator(navigationController: navigationController)
        childCoordinators.append(consumerCoordinator)
        consumerCoordinator.start()
    }
    
    func showTechnicianHome() {
        let technicianCoordinator = TechnicianCoordinator(navigationController: navigationController)
        childCoordinators.append(technicianCoordinator)
        technicianCoordinator.start()
    }
    
    func showAdminHome() {
        let adminCoordinator = AdminCoordinator(navigationController: navigationController)
        childCoordinators.append(adminCoordinator)
        adminCoordinator.start()
    }
}



