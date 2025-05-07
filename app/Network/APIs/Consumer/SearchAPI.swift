import Foundation

class SearchAPI {
    static let shared = SearchAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // Get service list
    func getServices(parameters: [String: Any], completion: @escaping (Result<[Service], Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        gateway.request("/services", method: .get, parameters: parameters, headers: headers) { (result: Result<ServicesResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.services))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get service details
    func getServiceDetails(id: String, completion: @escaping (Result<Service, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        gateway.request("/services/\(id)", method: .get, headers: headers) { (result: Result<ServiceResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.service))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get service category list
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AuthService.shared.getAccessToken() ?? "")"
        ]
        
        gateway.request("/services/categories", method: .get, headers: headers) { (result: Result<CategoriesResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.categories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// API response structures
struct ServicesResponse: Decodable {
    let success: Bool
    let services: [Service]
}

struct ServiceResponse: Decodable {
    let success: Bool
    let service: Service
}

struct CategoriesResponse: Decodable {
    let success: Bool
    let categories: [ServiceCategory]
}