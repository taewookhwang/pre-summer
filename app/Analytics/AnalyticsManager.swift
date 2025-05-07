import Foundation

class AnalyticsManager {
    // 로거 인스턴스
    private static var logger: AnalyticsLoggerProtocol?
    
    // 구성
    static func configure(with logger: AnalyticsLoggerProtocol) {
        self.logger = logger
        trackSystemEvent(SystemEvent(
            name: "analytics_initialized",
            parameters: ["timestamp": Date().timeIntervalSince1970]
        ))
    }
    
    // MARK: - 이벤트 트래킹 메서드
    
    // 비즈니스 이벤트
    static func trackBusinessEvent(_ event: BusinessEvent) {
        track(event: event)
    }
    
    // 소비자 이벤트
    static func trackConsumerEvent(_ event: ConsumerEvent) {
        track(event: event)
    }
    
    // 기술자 이벤트
    static func trackTechnicianEvent(_ event: TechnicianEvent) {
        track(event: event)
    }
    
    // 시스템 이벤트
    static func trackSystemEvent(_ event: AnalyticsEvent) {
        track(event: event)
    }
    
    // 일반 이벤트
    private static func track(event: AnalyticsEvent) {
        logger?.logEvent(
            name: event.name,
            parameters: event.parameters,
            category: event.category
        )
        
        #if DEBUG
        // 디버그 모드에서만 로그 출력
        print("📊 Analytics [\(event.category)] \(event.name): \(event.parameters)")
        #endif
    }
    
    // MARK: - 사용자 속성
    
    // 사용자 ID 설정
    static func setUserId(_ userId: String?) {
        logger?.setUserId(userId)
    }
    
    // 사용자 속성 설정
    static func setUserProperty(key: String, value: Any?) {
        logger?.setUserProperty(key: key, value: value)
    }
    
    // 모든 사용자 속성 제거
    static func clearUserProperties() {
        logger?.clearUserProperties()
    }
}