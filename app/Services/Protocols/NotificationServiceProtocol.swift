import Foundation
import UIKit

protocol NotificationServiceProtocol {
    // 알림 권한 요청 메서드
    func requestNotificationPermission(completion: @escaping (Bool) -> Void)
    
    // 알림 권한 상태 확인
    func checkNotificationPermission(completion: @escaping (NotificationPermissionStatus) -> Void)
    
    // 푸시 토큰 등록
    func registerPushToken(token: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 푸시 토큰 업데이트
    func updatePushToken(newToken: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 푸시 토큰 제거(로그아웃 시)
    func removePushToken(completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 주제 구독
    func subscribeToTopic(topic: NotificationTopic, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 주제 구독 해제
    func unsubscribeFromTopic(topic: NotificationTopic, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 로컬 알림 예약
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        triggerDate: Date,
        userInfo: [AnyHashable: Any]?,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    // 특정 ID의 로컬 알림 취소
    func cancelLocalNotification(identifier: String)
    
    // 모든 로컬 알림 취소
    func cancelAllLocalNotifications()
    
    // 알림 목록 가져오기
    func getNotifications(page: Int, limit: Int, completion: @escaping (Result<[NotificationItem], Error>) -> Void)
    
    // 알림 읽음 표시
    func markNotificationAsRead(notificationId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 모든 알림 읽음 표시
    func markAllNotificationsAsRead(completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 알림 삭제
    func deleteNotification(notificationId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 알림 설정 업데이트
    func updateNotificationSettings(settings: NotificationSettings, completion: @escaping (Result<Bool, Error>) -> Void)
    
    // 알림 설정 가져오기
    func getNotificationSettings(completion: @escaping (Result<NotificationSettings, Error>) -> Void)
    
    // 수신 알림 처리
    func handleReceivedNotification(userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void)
}

enum NotificationPermissionStatus {
    case authorized
    case denied
    case notDetermined
    case provisional // iOS 12+ provisional authorization
    case ephemeral   // iOS 14+ for app clips
}

enum NotificationTopic: String {
    case allUsers = "all_users"
    case technicians = "technicians"
    case consumers = "consumers"
    case admins = "admins"
    case promotions = "promotions"
    case serviceUpdates = "service_updates"
    case payments = "payments"
}

struct NotificationItem: Codable {
    let id: String
    let title: String
    let body: String
    let type: NotificationType
    let isRead: Bool
    let data: [String: String]?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, type, data
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

enum NotificationType: String, Codable {
    case reservation = "reservation"
    case jobUpdate = "job_update"
    case payment = "payment"
    case message = "message"
    case review = "review"
    case system = "system"
    case promotion = "promotion"
}

struct NotificationSettings: Codable {
    var enablePush: Bool
    var enableEmail: Bool
    var enableSMS: Bool
    var mutedTopics: [NotificationTopic]
    var quietHoursStart: Int?  // 0-23 시간
    var quietHoursEnd: Int?    // 0-23 시간
    
    enum CodingKeys: String, CodingKey {
        case enablePush = "enable_push"
        case enableEmail = "enable_email"
        case enableSMS = "enable_sms"
        case mutedTopics = "muted_topics"
        case quietHoursStart = "quiet_hours_start"
        case quietHoursEnd = "quiet_hours_end"
    }
    
    init(enablePush: Bool = true, enableEmail: Bool = true, enableSMS: Bool = true, 
         mutedTopics: [NotificationTopic] = [], quietHoursStart: Int? = nil, quietHoursEnd: Int? = nil) {
        self.enablePush = enablePush
        self.enableEmail = enableEmail
        self.enableSMS = enableSMS
        self.mutedTopics = mutedTopics
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enablePush = try container.decode(Bool.self, forKey: .enablePush)
        enableEmail = try container.decode(Bool.self, forKey: .enableEmail)
        enableSMS = try container.decode(Bool.self, forKey: .enableSMS)
        quietHoursStart = try container.decodeIfPresent(Int.self, forKey: .quietHoursStart)
        quietHoursEnd = try container.decodeIfPresent(Int.self, forKey: .quietHoursEnd)
        
        // Handle muted topics as string array and convert to NotificationTopic
        let topicStrings = try container.decode([String].self, forKey: .mutedTopics)
        mutedTopics = topicStrings.compactMap { NotificationTopic(rawValue: $0) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enablePush, forKey: .enablePush)
        try container.encode(enableEmail, forKey: .enableEmail)
        try container.encode(enableSMS, forKey: .enableSMS)
        try container.encodeIfPresent(quietHoursStart, forKey: .quietHoursStart)
        try container.encodeIfPresent(quietHoursEnd, forKey: .quietHoursEnd)
        
        // Convert NotificationTopic array to string array for encoding
        let topicStrings = mutedTopics.map { $0.rawValue }
        try container.encode(topicStrings, forKey: .mutedTopics)
    }
}