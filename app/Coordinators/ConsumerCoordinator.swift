import UIKit
import Foundation

class ConsumerCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHome()
    }
    
    func showHome() {
        let homeVC = HomeVC()
        homeVC.viewModel = HomeViewModel()
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    // Stub implementation - for features not fully implemented yet
    func showSearch() {
        /*
        let searchVC = SearchVC()
        searchVC.viewModel = SearchViewModel()
        searchVC.coordinator = self
        navigationController.pushViewController(searchVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Search feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    // Stub implementation - for features not fully implemented yet
    func showServiceRequest() {
        /*
        let requestVC = RequestServiceVC()
        requestVC.viewModel = RequestViewModel()
        requestVC.coordinator = self
        navigationController.pushViewController(requestVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Service request feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    // Stub implementation - for features not fully implemented yet
    func showReservationHistory() {
        /*
        let historyVC = ReservationHistoryVC()
        historyVC.viewModel = HomeViewModel() // Temporary, needs proper ViewModel
        historyVC.coordinator = self
        navigationController.pushViewController(historyVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Reservation history feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    // Create temporary stub classes for missing ViewControllers and ViewModels

    // Profile
    class ProfileVC: UIViewController {
        var coordinator: ConsumerCoordinator?
        var viewModel: ProfileViewModel?
    }
    
    class ProfileViewModel {
        // Empty implementation for now
    }
    
    // Review
    class ReviewVC: UIViewController {
        var coordinator: ConsumerCoordinator?
        var viewModel: ReviewViewModel?
    }
    
    class ReviewViewModel {
        init(reservation: Reservation) {
            // Initialize with reservation
        }
    }
    
    // ServiceMap
    class ServiceMapVC: UIViewController {
        var coordinator: ConsumerCoordinator?
    }
    
    // Cancel
    class CancelVC: UIViewController {
        var coordinator: ConsumerCoordinator?
        var viewModel: CancelViewModel?
    }
    
    class CancelViewModel {
        init(reservation: Reservation) {
            // Initialize with reservation
        }
    }
    
    // Payment
    class PaymentVC: UIViewController {
        var coordinator: ConsumerCoordinator?
        var viewModel: PaymentViewModel?
    }
    
    class PaymentViewModel {
        init(service: Service) {
            // Initialize with service
        }
    }
    
    // Chat room
    class ChatRoomVC: UIViewController {
        // Basic implementation
    }
    
    func showProfile() {
        let profileVC = ProfileVC()
        profileVC.viewModel = ProfileViewModel()
        profileVC.coordinator = self
        navigationController.pushViewController(profileVC, animated: true)
    }
    
    func showReview(for reservation: Reservation) {
        let reviewVC = ReviewVC()
        reviewVC.viewModel = ReviewViewModel(reservation: reservation)
        reviewVC.coordinator = self
        navigationController.pushViewController(reviewVC, animated: true)
    }
    
    func showServiceMap() {
        let mapVC = ServiceMapVC()
        mapVC.coordinator = self
        navigationController.pushViewController(mapVC, animated: true)
    }
    
    func showCancel(for reservation: Reservation) {
        let cancelVC = CancelVC()
        cancelVC.viewModel = CancelViewModel(reservation: reservation)
        cancelVC.coordinator = self
        navigationController.pushViewController(cancelVC, animated: true)
    }
    
    func showPayment(for service: Service) {
        let paymentVC = PaymentVC()
        paymentVC.viewModel = PaymentViewModel(service: service)
        paymentVC.coordinator = self
        navigationController.pushViewController(paymentVC, animated: true)
    }
    
    func showChat(for reservation: Reservation) {
        let chatVC = ChatRoomVC()
        // Chat room configuration logic (not implemented yet)
        navigationController.pushViewController(chatVC, animated: true)
    }
    
    func logout() {
        let authService = AuthService.shared
        // Logout handling (session reset)
        
        // Navigate to login screen
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        
        // Remove current coordinator and replace with Auth coordinator
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let appCoordinator = sceneDelegate.appCoordinator {
            appCoordinator.childCoordinators.removeAll { $0 is ConsumerCoordinator }
            appCoordinator.childCoordinators.append(authCoordinator)
        }
        
        authCoordinator.start()
    }
}