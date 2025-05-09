import Foundation

// EarningsAPI: 기술자 수입 데이터 조회를 위한 API 클래스
class EarningsAPI {
    static let shared = EarningsAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // 수입 요약 데이터 가져오기
    // period: 'daily', 'weekly', 'monthly', 'yearly'
    func getEarningsSummary(period: String, startDate: String, endDate: String, completion: @escaping (Result<EarningsSummaryResponse, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "period": period,
            "start_date": startDate,
            "end_date": endDate
        ]
        
        gateway.request("/technician/earnings/summary", method: .get, parameters: parameters, headers: headers) { (result: Result<EarningsSummaryResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 상세 수입 내역 가져오기 (페이지네이션 지원)
    func getEarningsDetails(startDate: String, endDate: String, page: Int = 1, limit: Int = 20, completion: @escaping (Result<EarningsDetailsResponse, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "start_date": startDate,
            "end_date": endDate,
            "page": page,
            "limit": limit
        ]
        
        gateway.request("/technician/earnings/details", method: .get, parameters: parameters, headers: headers) { (result: Result<EarningsDetailsResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 결제 방식 별 수입 통계 가져오기
    func getEarningsByPaymentMethod(startDate: String, endDate: String, completion: @escaping (Result<EarningsByPaymentMethodResponse, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "start_date": startDate,
            "end_date": endDate
        ]
        
        gateway.request("/technician/earnings/by-payment-method", method: .get, parameters: parameters, headers: headers) { (result: Result<EarningsByPaymentMethodResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 서비스 유형 별 수입 통계 가져오기
    func getEarningsByServiceType(startDate: String, endDate: String, completion: @escaping (Result<EarningsByServiceTypeResponse, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "start_date": startDate,
            "end_date": endDate
        ]
        
        gateway.request("/technician/earnings/by-service-type", method: .get, parameters: parameters, headers: headers) { (result: Result<EarningsByServiceTypeResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// API 응답 구조체
struct EarningsSummaryResponse: Decodable {
    let success: Bool
    let data: EarningsData
}

// 응답 구조체 정의
struct EarningsDetailsResponse: Decodable {
    let success: Bool
    let data: EarningsDetailsData
    let pagination: PaginationMeta?

    struct EarningsDetailsData: Decodable {
        let items: [EarningItem]

        struct EarningItem: Decodable {
            let id: String
            let date: String
            let jobId: String
            let serviceId: String
            let amount: Double
            let serviceName: String?
            let paymentMethod: String

            enum CodingKeys: String, CodingKey {
                case id
                case date
                case jobId = "job_id"
                case serviceId = "service_id"
                case amount
                case serviceName = "service_name"
                case paymentMethod = "payment_method"
            }

            // Custom decoder to handle type mismatches
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                // Required fields
                id = try container.decode(String.self, forKey: .id)
                date = try container.decode(String.self, forKey: .date)

                // Handle potential type mismatch for jobId
                if let jobIdInt = try? container.decode(Int.self, forKey: .jobId) {
                    jobId = String(jobIdInt)
                } else {
                    jobId = try container.decode(String.self, forKey: .jobId)
                }

                // Handle potential type mismatch for serviceId
                if let serviceIdInt = try? container.decode(Int.self, forKey: .serviceId) {
                    serviceId = String(serviceIdInt)
                } else {
                    serviceId = try container.decode(String.self, forKey: .serviceId)
                }

                // Handle potential type mismatch for amount (String to Double)
                if let amountString = try? container.decode(String.self, forKey: .amount),
                   let amountDouble = Double(amountString) {
                    amount = amountDouble
                } else {
                    amount = try container.decode(Double.self, forKey: .amount)
                }

                // Optional fields
                serviceName = try container.decodeIfPresent(String.self, forKey: .serviceName)

                // Handle potential type mismatch for paymentMethod
                if let paymentMethodInt = try? container.decode(Int.self, forKey: .paymentMethod) {
                    paymentMethod = String(paymentMethodInt)
                } else {
                    paymentMethod = try container.decode(String.self, forKey: .paymentMethod)
                }
            }
        }
    }
}

struct EarningsByPaymentMethodResponse: Decodable {
    let success: Bool
    let data: EarningsByPaymentMethodData
    
    struct EarningsByPaymentMethodData: Decodable {
        let total: Double
        let methods: [PaymentMethodData]
        
        struct PaymentMethodData: Decodable {
            let method: String
            let amount: Double
            let count: Int
            let percentage: Double
        }
    }
}

struct EarningsByServiceTypeResponse: Decodable {
    let success: Bool
    let data: EarningsByServiceTypeData
    
    struct EarningsByServiceTypeData: Decodable {
        let total: Double
        let services: [ServiceTypeData]
        
        struct ServiceTypeData: Decodable {
            let serviceId: String
            let serviceName: String
            let amount: Double
            let count: Int
            let percentage: Double
            
            enum CodingKeys: String, CodingKey {
                case serviceId = "service_id"
                case serviceName = "service_name"
                case amount
                case count
                case percentage
            }
        }
    }
}