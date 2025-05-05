import Foundation

class ServiceRepository {
    static let shared = ServiceRepository()
    
    private let servicesAPI = SearchAPI.shared
    
    private init() {}
    
    // 추천 서비스 조회
    func getFeaturedServices(completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["featured": true, "limit": 10]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // 서비스 목록 조회 (필터링 포함)
    func getServices(with filter: ServiceFilter, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params = filter.toParameters()
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
    
    // 서비스 상세 조회
    func getServiceDetails(id: Int, completion: @escaping (Result<Service, Error>) -> Void) {
        servicesAPI.getServiceDetails(id: id) { result in
            completion(result)
        }
    }
    
    // 서비스 카테고리 목록 조회
    func getServiceCategories(completion: @escaping (Result<[ServiceCategory], Error>) -> Void) {
        servicesAPI.getServiceCategories { result in
            completion(result)
        }
    }
    
    // 서비스 검색
    func searchServices(query: String, completion: @escaping (Result<[Service], Error>) -> Void) {
        let params: [String: Any] = ["query": query]
        
        servicesAPI.getServices(parameters: params) { result in
            completion(result)
        }
    }
}