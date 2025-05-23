import UIKit

// Required classes for Profile
class TechProfileVC: UIViewController {
    var coordinator: TechnicianCoordinator?
    var viewModel: TechProfileViewModel?
}

class TechProfileViewModel {
    // Empty implementation for now
}

// Use TechChatRoomVC for technician-specific chat room
class TechChatRoomVC: UIViewController {
    // Basic implementation for technician chat
}

class TechnicianCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showJobList()
    }
    
    func showJobList() {
        let jobListVC = JobListVC()
        jobListVC.viewModel = JobViewModel()
        jobListVC.coordinator = self
        navigationController.setViewControllers([jobListVC], animated: true)
    }
    
    func showJobDetail(job: Job) {
        // Navigate to job status update screen
        showJobStatusUpdate(job: job)
    }
    
    func navigateToJobDetail(jobId: String) {
        // Fetch the job using the ID and then navigate to detail
        let jobService = JobService.shared
        jobService.getJobDetail(
            jobId: jobId,
            onSuccess: { [weak self] job in
                guard let self = self else { return }
                self.showJobDetail(job: job)
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                // Show error alert
                let alert = UIAlertController(title: "오류", message: "작업을 찾을 수 없습니다: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.navigationController.present(alert, animated: true)
            }
        )
    }
    
    // Stub implementation - for features not fully implemented yet
    func showSchedule() {
        /*
        let scheduleVC = ScheduleVC()
        scheduleVC.viewModel = ScheduleViewModel()
        scheduleVC.coordinator = self
        navigationController.pushViewController(scheduleVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Schedule feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    // Stub implementation - for features not fully implemented yet
    func showEarnings() {
        /*
        let earningsVC = EarningsVC()
        earningsVC.viewModel = JobViewModel() // Temporary, needs proper ViewModel
        earningsVC.coordinator = self
        navigationController.pushViewController(earningsVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Earnings feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func showProfile() {
        let profileVC = TechProfileVC()
        profileVC.viewModel = TechProfileViewModel()
        profileVC.coordinator = self
        navigationController.pushViewController(profileVC, animated: true)
    }
    
    func showJobStatusUpdate(job: Job) {
        let statusUpdateVC = JobStatusUpdateVC()
        statusUpdateVC.viewModel = JobStatusUpdateViewModel(job: job)
        statusUpdateVC.coordinator = self
        navigationController.pushViewController(statusUpdateVC, animated: true)
    }
    
    // Stub implementation - for features not fully implemented yet
    func showJobPhotoUpload(job: Job) {
        /*
        let photoUploadVC = JobPhotoUploadVC()
        photoUploadVC.job = job
        photoUploadVC.coordinator = self
        navigationController.pushViewController(photoUploadVC, animated: true)
        */
        // Show alert for features not implemented yet
        let alert = UIAlertController(title: "Notice", message: "Job photo upload feature is not implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func showChat(for job: Job) {
        let chatVC = TechChatRoomVC()
        // Chat room configuration logic (not implemented yet)
        navigationController.pushViewController(chatVC, animated: true)
    }
    
    func logout() {
        // Logout handling (session reset)
        AuthService.shared.logout { _ in
            // Ignore result, we're navigating away regardless
        }
        
        // Navigate to login screen
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        
        // Remove current coordinator and replace with Auth coordinator
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let appCoordinator = sceneDelegate.appCoordinator {
            appCoordinator.childCoordinators.removeAll { $0 is TechnicianCoordinator }
            appCoordinator.childCoordinators.append(authCoordinator)
        }
        
        authCoordinator.start()
    }
}