import UIKit

class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // 토큰 확인하여 로그인 상태 체크
        if KeychainManager.shared.getToken(forKey: "accessToken") != nil {
            // 임시 구현 - 실제 화면이 구현되면 교체
            let loggedInVC = UIViewController()
            loggedInVC.view.backgroundColor = .white
            loggedInVC.title = "Already Logged In"
            navigationController.setViewControllers([loggedInVC], animated: false)
        } else {
            // 로그인 필요
            let authCoordinator = AuthCoordinator(navigationController: navigationController)
            childCoordinators.append(authCoordinator)
            authCoordinator.start()
        }
    }
    
    
    
    
    
    
    
    
    
    
    //func start() {
        // 토큰 확인하여 로그인 상태 체크
     //   if KeychainManager.shared.getToken(forKey: "accessToken") != nil {
            // 이미 로그인된 사용자
            // TODO: 토큰 유효성 검사 후 홈 화면으로 이동
     //       let homeVC = HomeVC()
      //      navigationController.setViewControllers([homeVC], animated: false)
      //  } else {
     //       // 로그인 필요
      //      let authCoordinator = AuthCoordinator(navigationController: navigationController)
     //       childCoordinators.append(authCoordinator)
     //       authCoordinator.start()
   //     }
   // }
}
