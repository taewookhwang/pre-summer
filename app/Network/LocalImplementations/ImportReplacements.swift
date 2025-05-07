import Foundation

// 다음 코드는 기존 import 문을 대체하는 역할을 합니다
// 실제 앱에서는 해당 import를 직접 사용해야 하지만,
// 빌드 문제를 해결하기 위해 빈 구현체를 제공합니다

// Firebase - 명시적으로 Mock 버전 참조
typealias FIRApp = MockFirebaseApp
typealias FIRAuth = MockAuth
typealias FIRUser = MockUser
typealias FIRAuthDataResult = MockAuthDataResult
typealias FIRMessaging = MockMessaging