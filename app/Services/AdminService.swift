import Foundation

// Changed DashboardData to AdminDashboardData to avoid name conflicts
struct AdminDashboardData {
    let activeUsers: Int
    let pendingReservations: Int
    let completedServices: Int
    let totalRevenue: Double
}

enum AdminServiceError: Error {
    case networkError(String)
    case serverError(String)
    case decodingError(String)
    
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Data decoding error: \(message)"
        }
    }
}

class AdminService {
    static let shared = AdminService()
    private let apiGateway = APIGateway.shared
    
    private init() {}
    
    // MARK: - Dashboard
    
    func getDashboardData(completion: @escaping (Result<AdminDashboardData, Error>) -> Void) {
        // In reality, an API call would be needed
        // For now, returning dummy data
        let dummyData = AdminDashboardData(
            activeUsers: 120,
            pendingReservations: 35,
            completedServices: 89,
            totalRevenue: 4850000
        )
        
        // Return dummy data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyData))
        }
    }
    
    func getHourlyServiceData(date: Date, completion: @escaping (Result<[(hour: Int, count: Int)], Error>) -> Void) {
        // In reality, an API call would be needed
        // For now, returning dummy data
        let hourlyData: [(hour: Int, count: Int)] = [
            (8, 2), (9, 5), (10, 8), (11, 12),
            (12, 6), (13, 9), (14, 15), (15, 10),
            (16, 7), (17, 5), (18, 3), (19, 1)
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(hourlyData))
        }
    }
    
    // MARK: - User Management
    
    func getUserList(completion: @escaping (Result<[AppUser], Error>) -> Void) {
        // In reality, this would need an API call
        // For now, returning dummy data
        let dummyUsers = [
            AppUser(id: 1, email: "consumer1@example.com", role: "consumer", name: "Consumer1", phone: "010-1234-5678", address: "Gangnam-gu, Seoul", createdAt: Date()),
            AppUser(id: 2, email: "consumer2@example.com", role: "consumer", name: "Consumer2", phone: "010-2345-6789", address: "Seocho-gu, Seoul", createdAt: Date()),
            AppUser(id: 3, email: "tech1@example.com", role: "technician", name: "Technician1", phone: "010-3456-7890", address: "Gangdong-gu, Seoul", createdAt: Date()),
            AppUser(id: 4, email: "tech2@example.com", role: "technician", name: "Technician2", phone: "010-4567-8901", address: "Songpa-gu, Seoul", createdAt: Date()),
            AppUser(id: 5, email: "admin@example.com", role: "admin", name: "Admin", phone: "010-5678-9012", address: "Jung-gu, Seoul", createdAt: Date())
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyUsers))
        }
    }
    
    func updateUserStatus(userId: Int, isActive: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        // In reality, an API call would be needed
        // For now, always return success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(true))
        }
    }
    
    // MARK: - Matching
    
    func getPendingReservations(completion: @escaping (Result<[Reservation], Error>) -> Void) {
        // In reality, this would need an API call
        // For now, returning dummy data
        let currentDate = Date()
        
        // Check if we need to modify the Reservation constructor or find an alternative approach
        // This is a temporary placeholder and might need adjustment based on the actual Reservation model
        let dummyReservations = [
            Reservation(
                id: "res1",
                userId: 1,
                serviceId: "svc1",
                technicianId: nil,
                reservationDate: currentDate.addingTimeInterval(3600),
                status: ReservationStatus.pending,
                address: "Teheran-ro 123, Gangnam-gu, Seoul",
                specialInstructions: "Door password: 1234",
                totalPrice: "120000",
                paymentStatus: "pending",
                createdAt: currentDate.addingTimeInterval(-86400),
                updatedAt: currentDate
            ),
            Reservation(
                id: "res2",
                userId: 2,
                serviceId: "svc2",
                technicianId: nil,
                reservationDate: currentDate.addingTimeInterval(7200),
                status: ReservationStatus.pending,
                address: "Seocho-daero 456, Seocho-gu, Seoul",
                specialInstructions: "Has a pet dog",
                totalPrice: "80000",
                paymentStatus: "pending",
                createdAt: currentDate.addingTimeInterval(-43200),
                updatedAt: currentDate
            )
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyReservations))
        }
    }
    
    func getAvailableTechnicians(date: Date, completion: @escaping (Result<[AppUser], Error>) -> Void) {
        // In reality, this would need an API call
        // For now, returning dummy data
        let dummyTechnicians = [
            AppUser(id: 3, email: "tech1@example.com", role: "technician", name: "Technician1", phone: "010-3456-7890", address: "Gangdong-gu, Seoul", createdAt: Date()),
            AppUser(id: 4, email: "tech2@example.com", role: "technician", name: "Technician2", phone: "010-4567-8901", address: "Songpa-gu, Seoul", createdAt: Date())
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(dummyTechnicians))
        }
    }
    
    func assignTechnician(reservationId: String, technicianId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        // In reality, an API call would be needed
        // For now, always return success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(true))
            
            // Log analytics event
            let event = TechnicianAssignedEvent(reservationId: reservationId, technicianId: technicianId)
            AnalyticsManager.trackBusinessEvent(event)
        }
    }
}

// MARK: - Analytics Events

struct TechnicianAssignedEvent: BusinessEvent {
    let reservationId: String
    let technicianId: Int
    
    var name: String {
        return "technician_assigned"
    }
    
    var parameters: [String : Any] {
        return [
            "reservation_id": reservationId,
            "technician_id": technicianId,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}