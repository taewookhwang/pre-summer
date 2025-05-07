import Foundation
import UIKit
import UserNotifications

class NotificationService: NSObject, NotificationServiceProtocol {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        setupNotificationCenter()
    }
    
    // UNUserNotificationCenter
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // 의존성
    private let firestoreManager = MockFirestore.firestore() // Firebase 모킹 레이어
    
    // MARK: - 초기화 및 설정 메서드
    
    private func setupNotificationCenter() {
        // 로컬 알림 델리게이트 설정
        notificationCenter.delegate = self
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(granted)
            
            if granted {
                // 푸시 등록을 UIApplication 메인 스레드에서 호출
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func checkNotificationPermission(completion: @escaping (NotificationPermissionStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(.authorized)
            case .denied:
                completion(.denied)
            case .notDetermined:
                completion(.notDetermined)
            case .provisional:
                completion(.provisional)
            case .ephemeral:
                completion(.ephemeral)
            @unknown default:
                completion(.notDetermined)
            }
        }
    }
    
    // MARK: - 푸시 토큰 관리 메서드
    
    func registerPushToken(token: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 현재 토큰을 서버에 저장
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        let tokenData: [String: Any] = [
            "token": token,
            "device": UIDevice.current.model,
            "os": "iOS",
            "os_version": UIDevice.current.systemVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            "created_at": Date()
        ]
        
        firestoreManager.collection("users")
            .document(String(currentUserId))
            .collection("push_tokens")
            .document(token)
            .setData(tokenData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    func updatePushToken(newToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 기존 토큰을 제거한 후 새 토큰 등록
        removePushToken { result in
            switch result {
            case .success:
                self.registerPushToken(token: newToken, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removePushToken(completion: @escaping (Result<Bool, Error>) -> Void) {
        // 현재 사용자의 푸시 토큰 제거
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        // 실제 환경의 토큰을 가져올 수가 없어 (모킹 레이어로 토큰을 알 수가 없으므로 직접 제거 불가)
        // 임시로 더미 토큰 사용
        let dummyToken = "dummy_token"
        
        firestoreManager.collection("users")
            .document(String(currentUserId))
            .collection("push_tokens")
            .document(dummyToken)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    // MARK: - 주제 구독 관리 메서드
    
    func subscribeToTopic(topic: NotificationTopic, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Firebase 메시징의 주제 구독 (모킹 레이어)
        MockMessaging.messaging().subscribe(toTopic: topic.rawValue)
        completion(.success(true))
    }
    
    func unsubscribeFromTopic(topic: NotificationTopic, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Firebase 메시징의 주제 구독 해제 (모킹 레이어)
        MockMessaging.messaging().unsubscribe(fromTopic: topic.rawValue)
        completion(.success(true))
    }
    
    // MARK: - 로컬 알림 관리 메서드
    
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        triggerDate: Date,
        userInfo: [AnyHashable: Any]?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let userInfo = userInfo {
            content.userInfo = userInfo
        }
        
        // 알림 트리거 설정
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // 알림 요청 객체 생성
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func cancelLocalNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllLocalNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - 알림 이력 관리 메서드
    
    func getNotifications(page: Int, limit: Int, completion: @escaping (Result<[NotificationItem], Error>) -> Void) {
        // 사용자 알림 목록 조회 (모킹 레이어)
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        // 모킹 알림 이력 생성
        var dummyNotifications: [NotificationItem] = []
        
        for i in 0..<5 {
            let notification = NotificationItem(
                id: "notification_\(i)",
                title: "알림 제목 \(i)",
                body: "알림 내용 \(i)",
                type: .system,
                isRead: false,
                data: ["key": "value"],
                createdAt: Date().addingTimeInterval(-Double(i * 3600))
            )
            
            dummyNotifications.append(notification)
        }
        
        completion(.success(dummyNotifications))
    }
    
    func markNotificationAsRead(notificationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 특정 알림을 읽음 상태로 업데이트 (모킹 레이어)
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        firestoreManager.collection("users")
            .document(String(currentUserId))
            .collection("notifications")
            .document(notificationId)
            .updateData(["is_read": true]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    func markAllNotificationsAsRead(completion: @escaping (Result<Bool, Error>) -> Void) {
        // 모든 알림을 읽음 상태로 변경 (모킹 레이어)
        completion(.success(true))
    }
    
    func deleteNotification(notificationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 특정 알림 항목 삭제 (모킹 레이어)
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        firestoreManager.collection("users")
            .document(String(currentUserId))
            .collection("notifications")
            .document(notificationId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    // MARK: - 알림 설정 관리 메서드
    
    func updateNotificationSettings(settings: NotificationSettings, completion: @escaping (Result<Bool, Error>) -> Void) {
        // 사용자 알림 설정 업데이트 저장 (모킹 레이어)
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        let settingsData: [String: Any] = [
            "enable_push": settings.enablePush,
            "enable_email": settings.enableEmail,
            "enable_sms": settings.enableSMS,
            "muted_topics": settings.mutedTopics.map { $0.rawValue },
            "quiet_hours_start": settings.quietHoursStart as Any,
            "quiet_hours_end": settings.quietHoursEnd as Any,
            "updated_at": Date()
        ]
        
        firestoreManager.collection("users")
            .document(String(currentUserId))
            .collection("settings")
            .document("notifications")
            .setData(settingsData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
    }
    
    func getNotificationSettings(completion: @escaping (Result<NotificationSettings, Error>) -> Void) {
        // 사용자 알림 설정 조회 (모킹 레이어)
        guard let currentUserId = UserRepository.shared.getCurrentUser()?.id else {
            completion(.failure(NotificationServiceError.userNotFound))
            return
        }
        
        // 기본 설정 반환
        let defaultSettings = NotificationSettings(
            enablePush: true,
            enableEmail: true,
            enableSMS: false,
            mutedTopics: [],
            quietHoursStart: nil,
            quietHoursEnd: nil
        )
        
        completion(.success(defaultSettings))
    }
    
    // MARK: - 알림 처리 메서드
    
    func handleReceivedNotification(userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        // 받은 알림 처리 (백그라운드에서나 앱 내에서 도착한 알림 처리)
        
        // 알림 이력 출력
        print("Received notification: \(userInfo)")
        
        // 알림 유형에 따른 처리
        if let type = userInfo["type"] as? String {
            switch type {
            case "message":
                // 메시지 알림 처리
                handleMessageNotification(userInfo)
            case "reservation":
                // 예약 알림 처리
                handleReservationNotification(userInfo)
            case "job_update":
                // 작업 업데이트 알림 처리
                handleJobUpdateNotification(userInfo)
            default:
                // 기타 알림 처리
                break
            }
        }
        
        completion(.newData)
    }
    
    // MARK: - 특정 알림 유형 처리 메서드
    
    private func handleMessageNotification(_ userInfo: [AnyHashable: Any]) {
        // 메시지 알림 처리 로직
        NotificationCenter.default.post(
            name: NSNotification.Name("NewMessageNotification"),
            object: nil,
            userInfo: userInfo
        )
    }
    
    private func handleReservationNotification(_ userInfo: [AnyHashable: Any]) {
        // 예약 알림 처리 로직
        NotificationCenter.default.post(
            name: NSNotification.Name("ReservationUpdateNotification"),
            object: nil,
            userInfo: userInfo
        )
    }
    
    private func handleJobUpdateNotification(_ userInfo: [AnyHashable: Any]) {
        // 작업 업데이트 알림 처리 로직
        NotificationCenter.default.post(
            name: NSNotification.Name("JobUpdateNotification"),
            object: nil,
            userInfo: userInfo
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // 알림이 백그라운드에 있을때 받을 때 호출됨
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 알림 이력
        let userInfo = notification.request.content.userInfo
        
        // 알림 표시 옵션 (iOS 14 이상에서는 배너 옵션 사용 가능)
        var options: UNNotificationPresentationOptions = [.sound, .badge]
        
        if #available(iOS 14.0, *) {
            options.insert(.banner)
        } else {
            options.insert(.alert)
        }
        
        // 적절한 유형에 알림 표시 여부 설정
        if let type = userInfo["type"] as? String, type == "message" {
            // 메시지 알림은 현재 채팅방에 들어가있는지 체크해서 알림 표시 여부 결정 필요
            
            // 임시로 모두 표시
            completionHandler(options)
        } else {
            // 기타 알림도 모두 표시
            completionHandler(options)
        }
    }
    
    // 알림을 탭한 경우 호출
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 알림 이력
        let userInfo = response.notification.request.content.userInfo
        
        // 알림 유형에 따라 화면으로 이동
        if let type = userInfo["type"] as? String {
            switch type {
            case "message":
                // 메시지 알림 - 채팅방으로 이동
                if let roomId = userInfo["room_id"] as? String {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenChatRoom"),
                        object: nil,
                        userInfo: ["roomId": roomId]
                    )
                }
            case "reservation":
                // 예약 알림 - 예약 상세 화면으로 이동
                if let reservationId = userInfo["reservation_id"] as? String {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenReservationDetail"),
                        object: nil,
                        userInfo: ["reservationId": reservationId]
                    )
                }
            case "job_update":
                // 작업 업데이트 알림 - 작업 상세 화면으로 이동
                if let jobId = userInfo["job_id"] as? String {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenJobDetail"),
                        object: nil,
                        userInfo: ["jobId": jobId]
                    )
                }
            default:
                break
            }
        }
        
        completionHandler()
    }
}

// MARK: - 오류 정의

enum NotificationServiceError: Error {
    case permissionDenied
    case tokenRegistrationFailed
    case userNotFound
    case networkError
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "알림 권한이 거부되었습니다. 설정에서 알림을 활성화하세요."
        case .tokenRegistrationFailed:
            return "푸시 토큰 등록에 실패했습니다."
        case .userNotFound:
            return "사용자 정보를 찾을 수 없습니다."
        case .networkError:
            return "네트워크 연결을 확인하세요."
        case .invalidData:
            return "잘못된 이력입니다."
        }
    }
}