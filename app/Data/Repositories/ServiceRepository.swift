import Foundation

class ServiceRepository {
    static let shared = ServiceRepository()
    
    private let servicesAPI = SearchAPI.shared
    
    private init() {}
    
    // îú D§ på
    func getFeaturedServices(completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["featured": true, "limit": 10]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // D§ ©] på (D0¡ Ïh)
    func getServices(with filter: ServiceFilter, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params = filter.toParameters()
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // D§ ¡8 på
    func getServiceDetails(id: Int, completion: @escaping (Result<Service, Error>) -> Void) {
        servicesAPI.getServiceDetails(id: id) { result in
            completion(result)
        }
    }
    
    // D§ tL‡¨ ©] på
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        servicesAPI.getServiceCategories { result in
            completion(result)
        }
    }
    
    // D§ Ä…
    func searchServices(query: String, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["query": query]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
}