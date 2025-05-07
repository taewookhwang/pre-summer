#!/bin/bash

# 이 스크립트는 잠시 디버깅을 위해 매우 극단적인 최소 빌드 환경을 설정합니다.
# 오로지 앱이 빌드되게 하는 것을 목표로 합니다.

echo "===== 극단적인 최소 빌드 준비 시작 ====="

# 1. 모든 Pod 제거 (디인테그레이션)
echo "1. CocoaPods 디인테그레이션 실행"
pod deintegrate

# 2. Firebase 및 Analytics 제거
echo "2. Firebase 및 Analytics 제거"
cd /Users/chris/projects/pre-summer-temp/app/HomeCleaningApp
cat > AppDelegate.swift << 'EOF'
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
EOF

cat > SceneDelegate.swift << 'EOF'
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let viewController = ViewController()
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
    }
}
EOF

cat > ViewController.swift << 'EOF'
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HomeCleaningApp"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
EOF

# 3. 임시로 필요한 프로토콜/클래스 생성
cd /Users/chris/projects/pre-summer-temp/app

# Create a very simple AnalyticsManager
mkdir -p Analytics
cat > Analytics/AnalyticsManager.swift << 'EOF'
import Foundation

struct AnalyticsManager {
    static func configure(with logger: Any) {}
    static func trackBusinessEvent(_ event: Any) {}
}
EOF

# 4. Xcode 프로젝트 설정 업데이트
echo "3. 빌드 시도..."

# 임시 빌드 명령 실행
cd /Users/chris/projects/pre-summer-temp/app

xcodebuild -project HomeCleaningApp.xcodeproj -scheme HomeCleaningApp -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug build ONLY_ACTIVE_ARCH=YES VALID_ARCHS=arm64 CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

echo "===== 완료 ====="
echo "빌드가 성공하면 이제 문제의 원인이 파악됩니다."
echo "문제 해결 후 원래 파일을 복원하세요."