import Foundation
import UIKit

// This file contains dummy implementations for iOS app building.
// It doesn't have actual functionality but includes classes and structures needed to resolve build errors.

// MARK: - Dummy API client and related types

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case multipartFormData
}

public enum APIError: Error {
    case invalidRequest
    case invalidResponse
    case networkError(Error)
    case serverError(Int, String)
    case decodingFailed(Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Invalid request."
        case .invalidResponse:
            return "Invalid response."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .decodingFailed(let error):
            return "Data conversion error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - WebSocket related dummy implementations

public class WebSocketManager {
    public static let shared = WebSocketManager()
    
    public var isConnected: Bool = false
    
    public func connect(url: URL, headers: [String: String]?, completion: @escaping (Result<Void, Error>) -> Void) {
        isConnected = true
        completion(.success(()))
    }
    
    public func disconnect() {
        isConnected = false
    }
    
    public func send(message: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    public func send(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    public var onMessage: ((Data) -> Void)?
    public var onStringMessage: ((String) -> Void)?
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
}

public class AdminDashboardSocket {
    public static let shared = AdminDashboardSocket()
    
    // Callback functions
    public var onJobUpdate: (([Job]) -> Void)?
    public var onLocationUpdate: ((Int, (latitude: Double, longitude: Double)) -> Void)?
    public var onDisconnect: (() -> Void)?
    
    public func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    public func disconnect() {}
}

public class ChatSocketManager {
    public static let shared = ChatSocketManager()
    
    public var onReceiveMessage: ((Message) -> Void)?
    public var onUserTyping: ((String) -> Void)?
    public var onUserOnlineStatusChange: ((String, Bool) -> Void)?
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    
    public func connectToRoom(roomId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    public func disconnect() {}
    
    public func sendMessage(roomId: String, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

public class MessageCache {
    public static let shared = MessageCache()
    
    public func getMessages(roomId: String) -> [Message] {
        return []
    }
    
    public func addMessage(roomId: String, message: Message) {}
    
    public func clearRoom(roomId: String) {}
}

// MARK: - Dummy SDK managers

public class DummyDanalSDKManager {
    public static let shared = DummyDanalSDKManager()
    
    public func requestPayment(amount: Double, productName: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("PAYMENT_ID_12345"))
    }
}

public class DummyFirebaseSDKManager {
    public static let shared = DummyFirebaseSDKManager()
    
    public func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("USER_ID_12345"))
    }
    
    public func signOut() -> Bool {
        return true
    }
}

public class DummyKakaoSDKManager {
    public static let shared = DummyKakaoSDKManager()
    
    public func login(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("KAKAO_USER_12345"))
    }
}

public class DummyNaverMapSDKManager {
    public static let shared = DummyNaverMapSDKManager()
    
    public func createMapController() -> UIViewController {
        return UIViewController()
    }
}

// MARK: - Dummy service classes

public class DummyAuthService {
    public static let shared = DummyAuthService()
    
    public func getCurrentUserId() -> String? {
        return "USER_12345"
    }
}

// MARK: - Dummy model classes

public struct Message {
    public var id: String
    public var senderId: String
    public var content: String
    public var type: MessageType
    public var timestamp: Date
    public var attachmentURL: String?
    
    public enum MessageType: String, Codable {
        case text
        case image
        case voice
        case location
    }
    
    public init(id: String, senderId: String, content: String, type: MessageType, timestamp: Date, attachmentURL: String? = nil) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.attachmentURL = attachmentURL
    }
}

public struct DummyServiceCategory {
    public var id: String
    public var name: String
    public var imageURL: String?
    
    public init(id: String, name: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}