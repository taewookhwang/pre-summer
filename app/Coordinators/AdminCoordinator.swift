import UIKit

class AdminCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    // Stub view controllers for missing implementations
    class PaymentReportVC: UIViewController {
        var coordinator: AdminCoordinator?
    }
    
    class ServiceAnalyticsVC: UIViewController {
        var coordinator: AdminCoordinator?
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showDashboard()
    }
    
    func showDashboard() {
        let dashboardVC = DashboardVC()
        dashboardVC.viewModel = DashboardViewModel()
        dashboardVC.coordinator = self
        navigationController.setViewControllers([dashboardVC], animated: true)
    }
    
    func showUserManagement() {
        let userManagementVC = UserManagementVC()
        userManagementVC.viewModel = UserManagementViewModel()
        userManagementVC.coordinator = self
        navigationController.pushViewController(userManagementVC, animated: true)
    }
    
    func showServiceMonitoring() {
        let serviceMonitoringVC = RealtimeMonitorVC()
        serviceMonitoringVC.viewModel = RealtimeMonitorViewModel()
        serviceMonitoringVC.coordinator = self
        navigationController.pushViewController(serviceMonitoringVC, animated: true)
    }
    
    func showMatching() {
        let matchingVC = MatchingVC()
        matchingVC.viewModel = MatchingViewModel()
        matchingVC.coordinator = self
        navigationController.pushViewController(matchingVC, animated: true)
    }
    
    func showPaymentReport() {
        let paymentReportVC = PaymentReportVC()
        paymentReportVC.coordinator = self
        navigationController.pushViewController(paymentReportVC, animated: true)
    }
    
    func showServiceAnalytics() {
        let serviceAnalyticsVC = ServiceAnalyticsVC()
        serviceAnalyticsVC.coordinator = self
        navigationController.pushViewController(serviceAnalyticsVC, animated: true)
    }
    
    func logout() {
        let authService = AuthService.shared
        // Handle logout (clear session)
        authService.logout { _ in }
        
        // Create authentication coordinator
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        
        // Remove current Admin coordinator from app coordinator and add Auth coordinator
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let appCoordinator = sceneDelegate.appCoordinator {
            appCoordinator.childCoordinators.removeAll { $0 is AdminCoordinator }
            appCoordinator.childCoordinators.append(authCoordinator)
        }
        
        authCoordinator.start()
    }
}