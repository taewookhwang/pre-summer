import Foundation

class ReservationRepository {
    static let shared = ReservationRepository()
    
    private let serviceHistoryAPI = ServiceHistoryAPI.shared
    private let requestServiceAPI = RequestServiceAPI.shared
    private let cancelAPI = CancelAPI.shared
    
    private init() {}
    
    // Get recent reservations
    func getRecentReservations(completion: @escaping (Result<[Reservation], Error>) -> Void) {
        let params: [String: Any] = ["limit": 5, "sort": "date_desc"]
        
        serviceHistoryAPI.getReservations(parameters: params) { result in
            completion(result)
        }
    }
    
    // Get reservation history (filter by status)
    func getReservationHistory(status: ReservationStatus? = nil, completion: @escaping (Result<[Reservation], Error>) -> Void) {
        var params: [String: Any] = [:]
        
        if let status = status {
            params["status"] = status.rawValue
        }
        
        serviceHistoryAPI.getReservations(parameters: params) { result in
            completion(result)
        }
    }
    
    // Get reservation details
    func getReservationDetails(id: String, completion: @escaping (Result<Reservation, Error>) -> Void) {
        serviceHistoryAPI.getReservationDetails(id: id) { result in
            completion(result)
        }
    }
    
    // Create new reservation
    func createReservation(request: ReservationRequest, completion: @escaping (Result<Reservation, Error>) -> Void) {
        requestServiceAPI.createReservation(request: request) { result in
            completion(result)
        }
    }
    
    // Cancel reservation
    func cancelReservation(request: CancellationRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        cancelAPI.cancelReservation(request: request) { result in
            completion(result)
        }
    }
}