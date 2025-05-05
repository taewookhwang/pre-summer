import Foundation

struct DashboardData {
    let activeUsers: Int
    let pendingReservations: Int
    let completedServices: Int
    let totalRevenue: Double
}

class AdminService {
    static let shared = AdminService()
    private let apiGateway = APIGateway.shared
    
    private init() {}
    
    func getDashboardData(completion: @escaping (Result<DashboardData, Error>) -> Void) {
        // ��\ T� pt0 X
        // � l�� API 8�\ ��
        let dummyData = DashboardData(
            activeUsers: 120,
            pendingReservations: 35,
            completedServices: 89,
            totalRevenue: 4850000
        )
        
        // D�0 ��| ܬtX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyData))
        }
    }
    
    func getUserList(completion: @escaping (Result<[User], Error>) -> Void) {
        // � l�� API 8�
        // ��\ H 0� X
        completion(.success([]))
    }
    
    func updateUserStatus(userId: Int, isActive: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        // � l�� API 8�
        completion(.success(true))
    }
}