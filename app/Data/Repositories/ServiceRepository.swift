import Foundation

class ServiceRepository {
    static let shared = ServiceRepository()
    
    private let servicesAPI = SearchAPI.shared
    
    private init() {}
    
    // Get featured services
    func getFeaturedServices(completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["featured": true, "limit": 10]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // Get service list (with filtering)
    func getServices(with filter: ServiceFilter, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params = filter.toParameters()
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // Get service details
    func getServiceDetails(id: String, completion: @escaping (Result<Service, Error>) -> Void) {
        servicesAPI.getServiceDetails(id: id) { result in
            completion(result)
        }
    }
    
    // Get service category list
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        servicesAPI.getServiceCategories { result in
            completion(result)
        }
    }
    
    // Search services
    func searchServices(query: String, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["query": query]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
}