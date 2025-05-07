import Foundation

// MARK: - 결제 서비스 관련 타입

// PaymentService에서 사용할 타입 정의
struct ServicePayment: Codable {
    let id: Int
    let reservationId: Int
    let amount: Double
    let status: ServicePaymentStatus
    let method: ServicePaymentMethod
    let transactionId: String
    let timestamp: Date
    let vbankInfo: VirtualBankInfo?
    let refundInfo: RefundInfo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reservationId = "reservation_id"
        case amount
        case status
        case method
        case transactionId = "transaction_id"
        case timestamp
        case vbankInfo = "vbank_info"
        case refundInfo = "refund_info"
    }
}

enum ServicePaymentMethod: String, Codable {
    case card = "card"      // 카드결제
    case vbank = "vbank"    // 가상계좌
    case trans = "trans"    // 계좌이체
}

enum ServicePaymentStatus: String, Codable {
    case pending = "pending"        // 대기 중
    case processing = "processing"  // 처리 중
    case completed = "completed"    // 완료됨
    case failed = "failed"          // 실패함
    case cancelled = "cancelled"    // 취소됨
    case refunded = "refunded"      // 환불됨
}

struct VirtualBankInfo: Codable {
    let bankName: String
    let accountNumber: String
    let dueDate: Date
    
    enum CodingKeys: String, CodingKey {
        case bankName = "bank_name"
        case accountNumber = "account_number"
        case dueDate = "due_date"
    }
}

struct RefundInfo: Codable {
    let amount: Double
    let reason: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case amount
        case reason
        case timestamp
    }
}

// MARK: - PG 서비스 결과 타입

struct PaymentGatewayResult {
    let transactionId: String
    let resultData: [String: Any]
    let bankName: String?
    let accountNumber: String?
    let dueDate: Date?
}

// MARK: - 결제 서비스

class PaymentService {
    static let shared = PaymentService()
    
    private init() {}
    
    // API 의존성
    private let paymentAPI = PaymentAPI.shared
    private let danalSDK = DanalSDKManager.shared
    
    // MARK: - 결제 처리 메서드
    
    // 결제 요청
    func requestPayment(
        reservationId: String,
        method: ServicePaymentMethod,
        amount: Double,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        // 결제 방식에 따른 처리
        switch method {
        case .card:
            processCardPayment(reservationId: reservationId, amount: amount, completion: completion)
        case .vbank:
            processVirtualBankPayment(reservationId: reservationId, amount: amount, completion: completion)
        case .trans:
            processDirectTransferPayment(reservationId: reservationId, amount: amount, completion: completion)
        }
    }
    
    // 카드 결제 처리
    private func processCardPayment(
        reservationId: String,
        amount: Double,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        // 결제 모듈 호출 (실제 SDK에서는 메서드명과 파라미터가 다를 수 있음)
        danalSDK.requestPayment(amount: amount, productName: "결제") { result in
            switch result {
            case .success(let paymentId):
                // API로 결제 정보 저장
                let paymentData: [String: Any] = [
                    "reservation_id": reservationId,
                    "amount": amount,
                    "method": ServicePaymentMethod.card.rawValue,
                    "transaction_id": paymentId,
                    "pg_result": ["status": "success"]
                ]
                
                self.savePaymentToServer(paymentData: paymentData, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 가상계좌 결제 처리
    private func processVirtualBankPayment(
        reservationId: String,
        amount: Double,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        // 결제 모듈 호출 (실제 환경에 맞게 수정 필요)
        danalSDK.requestPayment(amount: amount, productName: "가상계좌결제") { result in
            switch result {
            case .success(let paymentId):
                // 가상 은행 정보 생성 (실제 구현에서는 SDK에서 받아야 함)
                let bankInfo: [String: Any] = [
                    "bank_name": "신한은행",
                    "account_number": "110-123-456789",
                    "due_date": ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400))
                ]
                
                // API로 결제 정보 저장
                let paymentData: [String: Any] = [
                    "reservation_id": reservationId,
                    "amount": amount,
                    "method": ServicePaymentMethod.vbank.rawValue,
                    "transaction_id": paymentId,
                    "pg_result": ["status": "pending"],
                    "vbank_info": bankInfo
                ]
                
                self.savePaymentToServer(paymentData: paymentData, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 계좌이체 결제 처리
    private func processDirectTransferPayment(
        reservationId: String,
        amount: Double,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        // 결제 모듈 호출 (실제 환경에 맞게 수정 필요)
        danalSDK.requestPayment(amount: amount, productName: "계좌이체") { result in
            switch result {
            case .success(let paymentId):
                // API로 결제 정보 저장
                let paymentData: [String: Any] = [
                    "reservation_id": reservationId,
                    "amount": amount,
                    "method": ServicePaymentMethod.trans.rawValue,
                    "transaction_id": paymentId,
                    "pg_result": ["status": "completed"]
                ]
                
                self.savePaymentToServer(paymentData: paymentData, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 결제를 서버에 저장
    private func savePaymentToServer(
        paymentData: [String: Any],
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        paymentAPI.savePayment(paymentData: paymentData) { result in
            switch result {
            case .success(let paymentResponse):
                completion(.success(paymentResponse.payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 결제 취소
    func cancelPayment(
        paymentId: Int,
        reason: String,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        paymentAPI.cancelPayment(paymentId: paymentId, reason: reason) { result in
            switch result {
            case .success(let response):
                completion(.success(response.payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 결제 상태 확인
    func checkPaymentStatus(
        paymentId: Int,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        paymentAPI.getPaymentStatus(paymentId: paymentId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 예약에 대한 결제 정보 조회
    func getPaymentForReservation(
        reservationId: String,
        completion: @escaping (Result<ServicePayment, Error>) -> Void
    ) {
        paymentAPI.getPaymentForReservation(reservationId: reservationId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 결제 내역 조회
    func getPaymentHistory(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[ServicePayment], Error>) -> Void
    ) {
        paymentAPI.getPaymentHistory(page: page, limit: limit) { result in
            switch result {
            case .success(let response):
                completion(.success(response.payments))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 영수증 URL 조회
    func getReceiptURL(
        paymentId: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        paymentAPI.getReceiptURL(paymentId: paymentId) { result in
            switch result {
            case .success(let response):
                completion(.success(response.receiptURL))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - API 구현부

class PaymentAPI {
    static let shared = PaymentAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // 결제 정보 저장
    func savePayment(
        paymentData: [String: Any],
        completion: @escaping (Result<ServicePaymentResponse, APIError>) -> Void
    ) {
        let endpoint = "/payments"
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: paymentData,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 결제 취소
    func cancelPayment(
        paymentId: Int,
        reason: String,
        completion: @escaping (Result<ServicePaymentResponse, APIError>) -> Void
    ) {
        let endpoint = "/payments/\(paymentId)/cancel"
        
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
    
    // 결제 상태 확인
    func getPaymentStatus(
        paymentId: Int,
        completion: @escaping (Result<ServicePaymentResponse, APIError>) -> Void
    ) {
        let endpoint = "/payments/\(paymentId)"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 예약에 대한 결제 정보 조회
    func getPaymentForReservation(
        reservationId: String,
        completion: @escaping (Result<ServicePaymentResponse, APIError>) -> Void
    ) {
        let endpoint = "/reservations/\(reservationId)/payment"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 결제 내역 조회
    func getPaymentHistory(
        page: Int,
        limit: Int,
        completion: @escaping (Result<ServicePaymentHistoryResponse, APIError>) -> Void
    ) {
        let endpoint = "/payments/history"
        
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 영수증 URL 조회
    func getReceiptURL(
        paymentId: Int,
        completion: @escaping (Result<ReceiptURLResponse, APIError>) -> Void
    ) {
        let endpoint = "/payments/\(paymentId)/receipt"
        
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

// MARK: - 응답 모델

struct ServicePaymentResponse: Codable {
    let success: Bool
    let payment: ServicePayment
}

struct ServicePaymentHistoryResponse: Codable {
    let success: Bool
    let payments: [ServicePayment]
    let page: Int
    let totalPages: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case success, payments, page
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}

struct ReceiptURLResponse: Codable {
    let success: Bool
    let receiptURL: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case receiptURL = "receipt_url"
    }
}