import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // 나머지 메서드는 생략
}
