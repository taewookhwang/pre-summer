import UIKit

class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    private let authService = AuthService.shared
    private let userRepository = UserRepository.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // 토큰 확인하여 로그인 상태 체크
        if authService.isLoggedIn() {
            // 로그인된 사용자 처리
            navigateToUserHomeScreen()
        } else {
            // 로그인 필요
            showAuthScreen()
        }
    }
    
    private func navigateToUserHomeScreen() {
        // 사용자 역할에 따라 적절한 코디네이터 시작
        if let userRole = authService.getCurrentUserRole() {
            switch userRole {
            case "consumer":
                let consumerCoordinator = ConsumerCoordinator(navigationController: navigationController)
                childCoordinators.append(consumerCoordinator)
                consumerCoordinator.start()
                
            case "technician":
                let technicianCoordinator = TechnicianCoordinator(navigationController: navigationController)
                childCoordinators.append(technicianCoordinator)
                technicianCoordinator.start()
                
            case "admin":
                let adminCoordinator = AdminCoordinator(navigationController: navigationController)
                childCoordinators.append(adminCoordinator)
                adminCoordinator.start()
                
            default:
                // 알 수 없는 역할 처리
                print("Unknown user role: \(userRole)")
                showAuthScreen()
            }
        } else {
            // 사용자 역할을 찾을 수 없는 경우
            print("User role not found, redirecting to login")
            showAuthScreen()
        }
    }
    
    private func showAuthScreen() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
}
