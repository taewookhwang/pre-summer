import Foundation

class ServiceRepository {
    static let shared = ServiceRepository()
    
    private let servicesAPI = SearchAPI.shared
    
    private init() {}
    
    // Helper function to convert ServicesResponse to tuple
    private func convertToTuple(_ response: ServicesResponse) -> ([Service], PaginationMeta?) {
        return (response.services, response.pagination)
    }
    
    // Get featured services
    func getFeaturedServices(page: Int = 1, limit: Int = 10, completion: @escaping (Result<([Service], PaginationMeta?), Error>) -> Void) {
        var params: [String: Any] = ["featured": true, "limit": limit, "page": page]
        
        servicesAPI.getServices(parameters: params) { result in
            switch result {
            case .success(let response):
                completion(.success(self.convertToTuple(response)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get service list (with filtering)
    func getServices(with filter: ServiceFilter, page: Int = 1, limit: Int = 20, completion: @escaping (Result<([Service], PaginationMeta?), Error>) -> Void) {
        var params = filter.toParameters()
        params["page"] = page
        params["limit"] = limit
        
        servicesAPI.getServices(parameters: params) { result in
            switch result {
            case .success(let response):
                completion(.success(self.convertToTuple(response)))
            case .failure(let error):
                completion(.failure(error))
            }
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
    func searchServices(query: String, page: Int = 1, limit: Int = 20, completion: @escaping (Result<([Service], PaginationMeta?), Error>) -> Void) {
        var params: [String: Any] = ["query": query, "page": page, "limit": limit]
        
        servicesAPI.getServices(parameters: params) { result in
            switch result {
            case .success(let response):
                completion(.success(self.convertToTuple(response)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}