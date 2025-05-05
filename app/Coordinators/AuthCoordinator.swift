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
    
    // 회원가입 성공 후 알림을 표시하는 메서드
    func showRegistrationSuccess() {
        // 등록 성공 알림 표시
        let alert = UIAlertController(
            title: "등록 성공",
            message: "계정이 성공적으로 생성되었습니다. 로그인 화면으로 이동합니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            // 로그인 화면으로 이동
            self?.showLogin()
        })
        
        // 현재 보이는 화면에 알림 표시
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    
    // 로그인 성공 후 사용자 역할에 따라 적절한 홈 화면으로 이동
    func showHome(for user: UserDTO) {
        switch user.role {
        case "consumer":
            showConsumerHome()
        case "technician":
            showTechnicianHome()
        case "admin":
            showAdminHome()
        default:
            showConsumerHome() // 기본값
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



