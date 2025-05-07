import Foundation

protocol AnalyticsLoggerProtocol {
    // 이벤트 로깅
    func logEvent(name: String, parameters: [String: Any], category: String)
    
    // 사용자 속성 설정
    func setUserProperty(key: String, value: Any?)
    
    // 사용자 ID 설정
    func setUserId(_ userId: String?)
    
    // 사용자 속성 초기화
    func clearUserProperties()
}