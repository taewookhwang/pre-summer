import Foundation

class CancelAPI {
    static let shared = CancelAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // Cancel a reservation
    func cancelReservation(request: CancellationRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "reservation_id": request.reservationId,
            "reason": request.reason
        ]
        
        gateway.request("/reservations/cancel", method: .post, parameters: parameters, headers: headers) { (result: Result<CancelResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// API response structure
struct CancelResponse: Decodable {
    let success: Bool
    let message: String
}