import Foundation
import Alamofire

class ServiceHistoryAPI {
    static let shared = ServiceHistoryAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // } ©] på
    func getReservations(parameters: [String: Any], completion: @escaping (Result<[Reservation], Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        gateway.request("/reservations", method: .get, parameters: parameters, headers: headers) { (result: Result<ReservationsResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.reservations))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // } ¡8 på
    func getReservationDetails(id: Int, completion: @escaping (Result<Reservation, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        gateway.request("/reservations/\(id)", method: .get, headers: headers) { (result: Result<ReservationResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.reservation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// API Qı lp¥
struct ReservationsResponse: Decodable {
    let success: Bool
    let reservations: [Reservation]
}

struct ReservationResponse: Decodable {
    let success: Bool
    let reservation: Reservation
}