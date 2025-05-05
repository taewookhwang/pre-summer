import Foundation

class ServiceRepository {
    static let shared = ServiceRepository()
    
    private let servicesAPI = SearchAPI.shared
    
    private init() {}
    
    // �� D� p�
    func getFeaturedServices(completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["featured": true, "limit": 10]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // D� �] p� (D0� �h)
    func getServices(with filter: ServiceFilter, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params = filter.toParameters()
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // D� �8 p�
    func getServiceDetails(id: Int, completion: @escaping (Result<Service, Error>) -> Void) {
        servicesAPI.getServiceDetails(id: id) { result in
            completion(result)
        }
    }
    
    // D� tL� �] p�
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        servicesAPI.getServiceCategories { result in
            completion(result)
        }
    }
    
    // D� ��
    func searchServices(query: String, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["query": query]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
}