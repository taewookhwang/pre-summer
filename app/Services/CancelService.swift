import Foundation

class CancelService {
    static let shared = CancelService()
    
    private init() {}
    
    // API 의존성
    private let cancelAPI = NetworkCancelAPI.shared
    
    // 예약 취소
    func cancelReservation(reservationId: String, reason: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let cancellationRequest = CancelRequestModel(reservationId: reservationId, reason: reason)
        
        cancelAPI.cancelReservation(request: cancellationRequest) { result in
            switch result {
            case .success(let response):
                completion(.success(response.success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 취소 가능 여부 확인
    func checkCancellationEligibility(reservationId: String, completion: @escaping (Result<CancellationEligibility, APIError>) -> Void) {
        cancelAPI.checkCancellationEligibility(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.eligibility))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 취소 수수료 계산
    func calculateCancellationFee(reservationId: String, completion: @escaping (Result<CancellationFee, APIError>) -> Void) {
        cancelAPI.calculateCancellationFee(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.fee))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 취소 내역 조회
    func getCancellationHistory(completion: @escaping (Result<[CancellationRecord], APIError>) -> Void) {
        cancelAPI.getCancellationHistory { result in
            switch result {
            case .success(let response):
                completion(.success(response.cancellations))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// 모델
struct CancellationEligibility: Codable {
    let canCancel: Bool
    let reason: String?
    let fee: Double?
    
    enum CodingKeys: String, CodingKey {
        case canCancel = "can_cancel"
        case reason
        case fee
    }
}

struct CancellationFee: Codable {
    let amount: Double
    let currency: String
    let refundAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case refundAmount = "refund_amount"
    }
}

struct CancellationRecord: Codable {
    let reservationId: String
    let serviceName: String
    let cancelledAt: Date
    let reason: String
    let refundAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case reservationId = "reservation_id"
        case serviceName = "service_name"
        case cancelledAt = "cancelled_at"
        case reason
        case refundAmount = "refund_amount"
    }
}

// Placeholder API class
class NetworkCancelAPI {
    static let shared = NetworkCancelAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // 예약 취소 요청
    func cancelReservation(request: CancelRequestModel, completion: @escaping (Result<CancellationResponse, APIError>) -> Void) {
        let endpoint = "/reservations/cancel"
        
        let parameters: [String: Any] = [
            "reservation_id": request.reservationId,
            "reason": request.reason
        ]
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 취소 가능 여부 확인
    func checkCancellationEligibility(reservationId: String, completion: @escaping (Result<EligibilityResponse, APIError>) -> Void) {
        let endpoint = "/reservations/\(reservationId)/cancellation-eligibility"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 취소 수수료 계산
    func calculateCancellationFee(reservationId: String, completion: @escaping (Result<CancellationFeeResponse, APIError>) -> Void) {
        let endpoint = "/reservations/\(reservationId)/cancellation-fee"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 취소 내역 조회
    func getCancellationHistory(completion: @escaping (Result<CancellationHistoryResponse, APIError>) -> Void) {
        let endpoint = "/reservations/cancellation-history"
        
        apiGateway.request(
            endpoint,
            method: .get,
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
struct CancellationResponse: Codable {
    let success: Bool
    let message: String
    let reservation: Reservation?
}

struct EligibilityResponse: Codable {
    let success: Bool
    let eligibility: CancellationEligibility
}

struct CancellationFeeResponse: Codable {
    let success: Bool
    let fee: CancellationFee
}

struct CancellationHistoryResponse: Codable {
    let success: Bool
    let cancellations: [CancellationRecord]
}

struct CancelRequestModel {
    let reservationId: String
    let reason: String
}