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
    
    
    // AuthCoordinator.swift
    func showHome(for user: UserDTO) {
        // 임시 구현 - 실제 화면이 구현되면 교체
        let successVC = UIViewController()
        successVC.view.backgroundColor = .white
        successVC.title = "Login Success"
        
        navigationController.setViewControllers([successVC], animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // func showHome(for user: UserDTO) {
    //    switch user.role {
    //    case "consumer":
    //        showConsumerHome()
    //    case "technician":
    //        showTechnicianHome()
    //   case "admin":
    //        showAdminHome()
    //   default:
    //       showConsumerHome() // 기본값
    //   }
    // }
    
    func showConsumerHome() {
        // 임시 구현 - 실제 화면이 구현되면 교체
        let tempVC = UIViewController()
        tempVC.view.backgroundColor = .white
        tempVC.title = "Consumer Home"
        navigationController.setViewControllers([tempVC], animated: true)
    }
    
    func showTechnicianHome() {
        // 임시 구현 - 실제 화면이 구현되면 교체
        let tempVC = UIViewController()
        tempVC.view.backgroundColor = .white
        tempVC.title = "Technician Home"
        navigationController.setViewControllers([tempVC], animated: true)
    }
    
    func showAdminHome() {
        // 임시 구현 - 실제 화면이 구현되면 교체
        let tempVC = UIViewController()
        tempVC.view.backgroundColor = .white
        tempVC.title = "Admin Dashboard"
        navigationController.setViewControllers([tempVC], animated: true)
    }
}
