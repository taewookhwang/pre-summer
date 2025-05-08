import Foundation

class ReservationRepository {
    static let shared = ReservationRepository()
    
    private let serviceHistoryAPI = ServiceHistoryAPI.shared
    private let requestServiceAPI = RequestServiceAPI.shared
    private let cancelAPI = CancelAPI.shared
    
    private init() {}
    
    // Helper function to convert ReservationsResponse to tuple
    private func convertReservationResponse(_ response: ReservationsResponse) -> ([Reservation], PaginationMeta?) {
        return (response.reservations, response.pagination)
    }
    
    // Helper function to convert PaginatedResponse to tuple
    private func convertPaginatedResponse<T>(_ response: PaginatedResponse<T>) -> ([T], PaginationMeta?) {
        if let reservations = response.data as? [Reservation] {
            return (reservations, response.pagination)
        } else if let reservations = response.reservations {
            return (reservations, response.pagination)
        }
        return ([], response.pagination)
    }
    
    // Get recent reservations
    func getRecentReservations(page: Int = 1, limit: Int = 5, completion: @escaping (Result<([Reservation], PaginationMeta?), Error>) -> Void) {
        let params: [String: Any] = ["page": page, "limit": limit, "sort": "date_desc"]
        
        serviceHistoryAPI.getReservations(parameters: params) { result in
            switch result {
            case .success(let response):
                completion(.success(self.convertReservationResponse(response)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get reservation history (filter by status)
    func getReservationHistory(status: ReservationStatus? = nil, page: Int = 1, limit: Int = 20, completion: @escaping (Result<([Reservation], PaginationMeta?), Error>) -> Void) {
        var params: [String: Any] = ["page": page, "limit": limit]
        
        if let status = status {
            params["status"] = status.rawValue
        }
        
        serviceHistoryAPI.getReservations(parameters: params) { result in
            switch result {
            case .success(let response):
                completion(.success(self.convertReservationResponse(response)))
            case .failure(let error):
                completion(.failure(error))
            }
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