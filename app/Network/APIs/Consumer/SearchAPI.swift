import Foundation
import Alamofire

class SearchAPI {
    static let shared = SearchAPI()
    private let gateway = APIGateway.shared
    
    private init() {}
    
    // D� �] p�
    func getServices(parameters: [String: Any], completion: @escaping (Result<[Service], Error>) -> Void) {
        let headers: HTTPHeaders = [
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
    
    // D� �8 p�
    func getServiceDetails(id: Int, completion: @escaping (Result<Service, Error>) -> Void) {
        let headers: HTTPHeaders = [
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
    
    // D� tL� �] p�
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        let headers: HTTPHeaders = [
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

// API Q� lp�
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