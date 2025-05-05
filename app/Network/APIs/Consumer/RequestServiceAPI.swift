import Foundation
import Alamofire

class RequestServiceAPI {
    static let shared = RequestServiceAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // � } �1
    func createReservation(request: ReservationRequest, completion: @escaping (Result<Reservation, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "service_id": request.serviceId,
            "date_time": ISO8601DateFormatter().string(from: request.dateTime),
            "address": request.address,
            "special_instructions": request.specialInstructions ?? ""
        ]
        
        gateway.request("/reservations", method: .post, parameters: parameters, headers: headers) { (result: Result<ReservationResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.reservation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // } 
    func updateReservation(id: Int, request: ReservationRequest, completion: @escaping (Result<Reservation, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        let parameters: [String: Any] = [
            "service_id": request.serviceId,
            "date_time": ISO8601DateFormatter().string(from: request.dateTime),
            "address": request.address,
            "special_instructions": request.specialInstructions ?? ""
        ]
        
        gateway.request("/reservations/\(id)", method: .put, parameters: parameters, headers: headers) { (result: Result<ReservationResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.reservation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}