import Foundation

class ServiceHistoryAPI {
    static let shared = ServiceHistoryAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // Get reservation list
    func getReservations(parameters: [String: Any], completion: @escaping (Result<[Reservation], Error>) -> Void) {
        let headers: [String: String] = [
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
    
    // Get reservation details
    func getReservationDetails(id: String, completion: @escaping (Result<Reservation, Error>) -> Void) {
        let headers: [String: String] = [
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

// API response structures
struct ReservationsResponse: Decodable {
    let success: Bool
    let reservations: [Reservation]
}

struct ReservationResponse: Decodable {
    let success: Bool
    let reservation: Reservation
}