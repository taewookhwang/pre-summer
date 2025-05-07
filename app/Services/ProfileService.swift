import Foundation
import UIKit

class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    // 의존성
    private let profileAPI = ProfileAPI.shared
    private let mediaService = MediaService.shared
    private let userRepository = UserRepository.shared
    
    // MARK: - 프로필 관련 기능
    
    // 현재 사용자 프로필 가져오기
    func getCurrentUserProfile(completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        guard let userId = userRepository.getCurrentUser()?.id else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        getUserProfile(userId: userId, completion: completion)
    }
    
    // 특정 사용자의 프로필 가져오기
    func getUserProfile(userId: Int, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        profileAPI.getUserProfile(userId: userId) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 프로필 업데이트
    func updateProfile(
        name: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        bio: String? = nil,
        completion: @escaping (Result<ProfileResponse, Error>) -> Void
    ) {
        guard let userId = userRepository.getCurrentUser()?.id else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        var profileData: [String: Any] = [:]
        
        if let name = name {
            profileData["name"] = name
        }
        
        if let phone = phone {
            profileData["phone"] = phone
        }
        
        if let address = address {
            profileData["address"] = address
        }
        
        if let bio = bio {
            profileData["bio"] = bio
        }
        
        profileAPI.updateProfile(userId: userId, profileData: profileData) { result in
            switch result {
            case .success(let response):
                // 로컬 사용자 데이터 업데이트
                if let user = self.userRepository.getCurrentUser() {
                    _ = self.userRepository.updateUserProfile(
                        name: name ?? user.name,
                        phone: phone ?? user.phone,
                        address: address ?? user.address
                    )
                }
                
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 프로필 이미지 업로드
    func uploadProfileImage(image: UIImage, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        guard let userId = userRepository.getCurrentUser()?.id else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        // 이미지 업로드
        mediaService.uploadImage(image: image, type: .userProfile) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageUrl):
                // 프로필 업데이트
                let profileData: [String: Any] = [
                    "profile_image_url": imageUrl
                ]
                
                self.profileAPI.updateProfile(userId: userId, profileData: profileData) { result in
                    switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 비밀번호 변경
    func changePassword(
        currentPassword: String,
        newPassword: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard userRepository.getCurrentUser() != nil else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        profileAPI.changePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 계정 설정 가져오기
    func getAccountSettings(completion: @escaping (Result<AccountSettings, Error>) -> Void) {
        guard let userId = userRepository.getCurrentUser()?.id else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        profileAPI.getAccountSettings(userId: userId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.settings))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 계정 설정 업데이트
    func updateAccountSettings(
        settings: AccountSettings,
        completion: @escaping (Result<AccountSettings, Error>) -> Void
    ) {
        guard let userId = userRepository.getCurrentUser()?.id else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        profileAPI.updateAccountSettings(userId: userId, settings: settings) { result in
            switch result {
            case .success(let response):
                completion(.success(response.settings))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 프로필 계정 삭제
    func requestAccountDeletion(reason: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard userRepository.getCurrentUser() != nil else {
            completion(.failure(ProfileError.userNotFound))
            return
        }
        
        profileAPI.requestAccountDeletion(reason: reason) { result in
            switch result {
            case .success(let response):
                completion(.success(response.success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - 모델

struct ProfileResponse: Codable {
    let success: Bool
    let user: AppUser
    let additionalInfo: AdditionalProfileInfo?
    
    enum CodingKeys: String, CodingKey {
        case success, user
        case additionalInfo = "additional_info"
    }
}

struct AdditionalProfileInfo: Codable {
    let bio: String?
    let profileImageURL: String?
    let completedJobs: Int?
    let rating: Double?
    let reviewCount: Int?
    let memberSince: Date?
    
    enum CodingKeys: String, CodingKey {
        case bio
        case profileImageURL = "profile_image_url"
        case completedJobs = "completed_jobs"
        case rating
        case reviewCount = "review_count"
        case memberSince = "member_since"
    }
}

struct AccountSettings: Codable {
    var language: String
    var currency: String
    var dateFormat: String
    var timeFormat: String
    var emailNotifications: Bool
    var pushNotifications: Bool
    var smsNotifications: Bool
    var privacySettings: PrivacySettings
    
    enum CodingKeys: String, CodingKey {
        case language
        case currency
        case dateFormat = "date_format"
        case timeFormat = "time_format"
        case emailNotifications = "email_notifications"
        case pushNotifications = "push_notifications"
        case smsNotifications = "sms_notifications"
        case privacySettings = "privacy_settings"
    }
}

struct PrivacySettings: Codable {
    var showProfileToPublic: Bool
    var showContactInfo: Bool
    var shareLocation: Bool
    var allowAnalytics: Bool
    
    enum CodingKeys: String, CodingKey {
        case showProfileToPublic = "show_profile_to_public"
        case showContactInfo = "show_contact_info"
        case shareLocation = "share_location"
        case allowAnalytics = "allow_analytics"
    }
}

// MARK: - 오류 정의

enum ProfileError: Error {
    case userNotFound
    case invalidData
    case updateFailed
    case imageUploadFailed
    
    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "사용자를 찾을 수 없습니다."
        case .invalidData:
            return "잘못된 데이터입니다."
        case .updateFailed:
            return "프로필 업데이트에 실패했습니다."
        case .imageUploadFailed:
            return "이미지 업로드에 실패했습니다."
        }
    }
}

// MARK: - API 구현부

class ProfileAPI {
    static let shared = ProfileAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // 사용자 프로필 가져오기
    func getUserProfile(
        userId: Int,
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        let endpoint = "/users/\(userId)/profile"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 프로필 업데이트
    func updateProfile(
        userId: Int,
        profileData: [String: Any],
        completion: @escaping (Result<ProfileResponse, APIError>) -> Void
    ) {
        let endpoint = "/users/\(userId)/profile"
        
        apiGateway.request(
            endpoint,
            method: .put,
            parameters: profileData,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 비밀번호 변경
    func changePassword(
        currentPassword: String,
        newPassword: String,
        completion: @escaping (Result<Bool, APIError>) -> Void
    ) {
        let endpoint = "/auth/change-password"
        
        let parameters: [String: Any] = [
            "current_password": currentPassword,
            "new_password": newPassword
        ]
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<SuccessResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 계정 설정 가져오기
    func getAccountSettings(
        userId: Int,
        completion: @escaping (Result<AccountSettingsResponse, APIError>) -> Void
    ) {
        let endpoint = "/users/\(userId)/settings"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 계정 설정 업데이트
    func updateAccountSettings(
        userId: Int,
        settings: AccountSettings,
        completion: @escaping (Result<AccountSettingsResponse, APIError>) -> Void
    ) {
        let endpoint = "/users/\(userId)/settings"
        
        // 코덱을 사용해서 설정을 Dictionary로 변환
        guard let settingsData = try? JSONEncoder().encode(settings),
              let parameters = try? JSONSerialization.jsonObject(with: settingsData) as? [String: Any] else {
            let decodingError = NSError(domain: "ProfileAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "설정 데이터 변환 실패"])
            let error = APIError.decodingError(decodingError)
            completion(.failure(error))
            return
        }
        
        apiGateway.request(
            endpoint,
            method: .put,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 계정 삭제 요청
    func requestAccountDeletion(
        reason: String,
        completion: @escaping (Result<SuccessResponse, APIError>) -> Void
    ) {
        let endpoint = "/users/delete-account"
        
        let parameters: [String: Any] = [
            "reason": reason
        ]
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // Helper to get auth token
    private func getAuthToken() -> String {
        return KeychainManager.shared.getToken(forKey: "accessToken") ?? ""
    }
}

// MARK: - 응답 모델

struct AccountSettingsResponse: Codable {
    let success: Bool
    let settings: AccountSettings
}

struct SuccessResponse: Codable {
    let success: Bool
    let message: String?
}