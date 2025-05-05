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
        // „Ü\ Tø pt0 X
        // ä lÐ” API 8œ\ À½
        let dummyData = DashboardData(
            activeUsers: 120,
            pendingReservations: 35,
            completedServices: 89,
            totalRevenue: 4850000
        )
        
        // DÙ0 ˜¬| Ü¬tX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyData))
        }
    }
    
    func getUserList(completion: @escaping (Result<[User], Error>) -> Void) {
        // ä lÐ” API 8œ
        // „Ü\ H 0ô X
        completion(.success([]))
    }
    
    func updateUserStatus(userId: Int, isActive: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        // ä lÐ” API 8œ
        completion(.success(true))
    }
}