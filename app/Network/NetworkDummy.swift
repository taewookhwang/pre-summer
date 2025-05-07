import Foundation
import UIKit

// This file contains dummy implementations of all network-related components 
// that are referenced in various ViewModels but may not be fully implemented yet.
// This should help resolve build errors.

// MARK: - WebSocket Implementations

class WebSocketProtocolDummy: WebSocketProtocol {
    var isConnected: Bool = false
    var onMessage: ((Data) -> Void)?
    var onStringMessage: ((String) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    func connect(url: URL, headers: [String: String]?, completion: @escaping (Result<Void, Error>) -> Void) {
        isConnected = true
        onConnect?()
        completion(.success(()))
    }
    
    func disconnect() {
        isConnected = false
        onDisconnect?(nil)
    }
    
    func send(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func send(message: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

// MARK: - SDK Implementations

class SDKManagerDummy {
    static let shared = SDKManagerDummy()
    
    private init() {}
    
    func initialize() {
        Logger.info("Dummy SDK initialized")
    }
    
    func handleEvent(name: String, parameters: [String: Any]?) {
        Logger.debug("Dummy SDK event handled: \(name)")
    }
}

// MARK: - Model Stubs for ViewModel Dependencies

struct DashboardData {
    let activeUsers: Int
    let pendingReservations: Int
    let completedServices: Int
    let totalRevenue: Double
    
    static func mockData() -> DashboardData {
        return DashboardData(
            activeUsers: 127,
            pendingReservations: 15,
            completedServices: 42,
            totalRevenue: 15200.0
        )
    }
}

struct MatchingData {
    let pendingMatches: Int
    let averageMatchTime: TimeInterval
    let technicianAvailability: Double // Percentage
    
    static func mockData() -> MatchingData {
        return MatchingData(
            pendingMatches: 8,
            averageMatchTime: 23.5,
            technicianAvailability: 0.75
        )
    }
}

struct MonitoringData {
    let activeTechnicians: Int
    let onWayJobs: Int
    let inProgressJobs: Int
    let completedToday: Int
    
    static func mockData() -> MonitoringData {
        return MonitoringData(
            activeTechnicians: 15,
            onWayJobs: 4,
            inProgressJobs: 7,
            completedToday: 22
        )
    }
}

// MARK: - Dummy Auth Components

struct AuthCredentials {
    let email: String
    let password: String
}

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .networkError: return "Network connection error"
        case .serverError: return "Server error occurred"
        }
    }
}

// MARK: - Payment UI Display Helpers

struct DummyPaymentMethodUI {
    let id: String
    let type: String
    let name: String
    let isDefault: Bool
}

// UI Extension for PaymentStatus
extension PaymentStatus {
    var displayName: String {
        switch self {
        case .pending: return "결제 대기"
        case .completed: return "완료"
        case .failed: return "실패"
        case .refunded: return "환불"
        case .cancelled: return "취소"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending: return .systemYellow
        case .completed: return .systemGreen
        case .failed: return .systemRed
        case .refunded: return .systemGray
        case .cancelled: return .systemOrange
        }
    }
}

// This ensures all necessary Firebase dependencies are properly stubbed
class FirebaseSDKManagerStub {
    static let shared = FirebaseSDKManagerStub()
    
    func initialize() {
        Logger.info("Firebase SDK initialized (stub)")
    }
    
    func configure() {
        // This would normally set up Firebase
        Logger.info("Firebase configured (stub)")
    }
}