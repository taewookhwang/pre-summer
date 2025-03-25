import UIKit

protocol CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
