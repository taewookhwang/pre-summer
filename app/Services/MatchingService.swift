import Foundation

class MatchingService {
    static let shared = MatchingService()
    
    private init() {}
    
    // API 의존성
    private let matchingAPI = MatchingAPI.shared
    
    // 예약에 사용 가능한 기술자 목록 조회
    func getAvailableTechnicians(
        reservationId: String,
        completion: @escaping (Result<[MatchingTechnician], APIError>) -> Void
    ) {
        matchingAPI.getAvailableTechnicians(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.technicians))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 기술자 매칭 요청
    func matchTechnician(
        reservationId: String,
        technicianId: Int,
        completion: @escaping (Result<Reservation, APIError>) -> Void
    ) {
        matchingAPI.matchTechnician(
            reservationId: reservationId,
            technicianId: technicianId
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.reservation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 자동 매칭 요청
    func requestAutoMatching(
        reservationId: String,
        completion: @escaping (Result<MatchingStatus, APIError>) -> Void
    ) {
        matchingAPI.requestAutoMatching(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.status))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 매칭 상태 확인
    func checkMatchingStatus(
        reservationId: String,
        completion: @escaping (Result<MatchingStatus, APIError>) -> Void
    ) {
        matchingAPI.checkMatchingStatus(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.status))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 매칭 취소
    func cancelMatching(
        reservationId: String,
        completion: @escaping (Result<Bool, APIError>) -> Void
    ) {
        matchingAPI.cancelMatching(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 특정 기술자에게 직접 매칭 요청
    func requestDirectMatching(
        reservationId: String,
        technicianId: Int,
        message: String? = nil,
        completion: @escaping (Result<MatchingStatus, APIError>) -> Void
    ) {
        matchingAPI.requestDirectMatching(
            reservationId: reservationId,
            technicianId: technicianId,
            message: message
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.status))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// 모델
struct MatchingTechnician: Codable {
    let id: Int
    let name: String
    let rating: Double
    let reviewCount: Int
    let completedJobs: Int
    let distance: Double? // km 단위
    let availableTime: Date?
    let profileImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, rating, distance
        case reviewCount = "review_count"
        case completedJobs = "completed_jobs"
        case availableTime = "available_time"
        case profileImageURL = "profile_image_url"
    }
}

struct MatchingStatus: Codable {
    let reservationId: String
    let status: MatchingStatusType
    let technicianId: Int?
    let technician: MatchingTechnician?
    let estimatedArrivalTime: Date?
    let expiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case reservationId = "reservation_id"
        case status
        case technicianId = "technician_id"
        case technician
        case estimatedArrivalTime = "estimated_arrival_time"
        case expiresAt = "expires_at"
    }
}

enum MatchingStatusType: String, Codable {
    case pending = "pending"
    case searching = "searching"
    case offered = "offered"
    case matched = "matched"
    case failed = "failed"
    case cancelled = "cancelled"
}

// Placeholder API class
class MatchingAPI {
    static let shared = MatchingAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // 예약에 사용 가능한 기술자 목록 조회
    func getAvailableTechnicians(
        reservationId: String,
        completion: @escaping (Result<AvailableTechniciansResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/available-technicians"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 기술자 매칭 요청
    func matchTechnician(
        reservationId: String,
        technicianId: Int,
        completion: @escaping (Result<MatchingResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/match"
        
        let parameters: [String: Any] = [
            "technician_id": technicianId
        ]
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 자동 매칭 요청
    func requestAutoMatching(
        reservationId: String,
        completion: @escaping (Result<MatchingStatusResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/auto-match"
        
        apiGateway.request(
            endpoint,
            method: .post,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 매칭 상태 확인
    func checkMatchingStatus(
        reservationId: String,
        completion: @escaping (Result<MatchingStatusResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/matching-status"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 매칭 취소
    func cancelMatching(
        reservationId: String,
        completion: @escaping (Result<CancelMatchingResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/cancel-matching"
        
        apiGateway.request(
            endpoint,
            method: .post,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 특정 기술자에게 직접 매칭 요청
    func requestDirectMatching(
        reservationId: String,
        technicianId: Int,
        message: String? = nil,
        completion: @escaping (Result<MatchingStatusResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/direct-match"
        
        var parameters: [String: Any] = [
            "technician_id": technicianId
        ]
        
        if let message = message {
            parameters["message"] = message
        }
        
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

// Response models
struct AvailableTechniciansResponse: Codable {
    let success: Bool
    let technicians: [MatchingTechnician]
}

struct MatchingResponse: Codable {
    let success: Bool
    let reservation: Reservation
}

struct MatchingStatusResponse: Codable {
    let success: Bool
    let status: MatchingStatus
}

struct CancelMatchingResponse: Codable {
    let success: Bool
    let message: String
}