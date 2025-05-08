import Foundation

extension Notification.Name {
    /// 사용자 세션 만료 알림
    static let userSessionExpired = Notification.Name("userSessionExpired")
    
    /// 토큰 만료 알림 (이미 구현되어 있는 경우를 위한 별칭)
    static let tokenExpired = Notification.Name("TokenExpired")
}