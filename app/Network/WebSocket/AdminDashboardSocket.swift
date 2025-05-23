import Foundation

class AdminDashboardSocket {
    static let shared = AdminDashboardSocket()
    private init() {}
    
    func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func disconnect() {}
}
