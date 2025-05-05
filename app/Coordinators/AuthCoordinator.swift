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
    
    // 수정된 showHome 메서드
    func showHome(for user: UserDTO) {
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



// 아래 주석 처리된 코드는 로그인 후 사용자 역할별 홈 화면으로 이동하기 위한 코드입니다.
// 등록 후에는 위의 showHome 메서드를 사용하고, 로그인 성공 후에는 이 메서드를 호출하도록 수정해야 합니다.

/*
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
*/
