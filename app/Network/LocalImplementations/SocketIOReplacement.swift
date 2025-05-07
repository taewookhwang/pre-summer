import Foundation

// Socket.IO 대체 구현 - 이름 충돌 방지를 위해 Mock 접두어 사용
class MockSocketManager {
    static func socket(forNamespace nsp: String = "/") -> MockSocketIOClient {
        return MockSocketIOClient(manager: MockSocketManager(), nsp: nsp)
    }
    
    #if DEBUG
    init(socketURL: URL = URL(string: "http://localhost:3000")!, config: MockSocketIOClientConfiguration = []) {}
    #else
    init(socketURL: URL = URL(string: "https://api.yourproductionserver.com")!, config: MockSocketIOClientConfiguration = []) {}
    #endif
}

class MockSocketIOClient {
    init(manager: MockSocketManager, nsp: String) {}
    
    func connect() {}
    func disconnect() {}
    
    func on(_ event: String, callback: @escaping ([Any]) -> Void) -> UUID {
        return UUID()
    }
    
    func emit(_ event: String, _ items: Any...) {}
}

typealias MockSocketIOClientConfiguration = [MockSocketIOClientOption]

enum MockSocketIOClientOption {
    case connectParams([String: Any])
    case secure(Bool)
    case reconnects(Bool)
    case reconnectWait(Int)
    case log(Bool)
    case forceWebsockets(Bool)
}

// 기존 Socket.IO 클래스를 Mock 버전으로 별칭 지정
typealias SocketManager = MockSocketManager
typealias SocketIOClient = MockSocketIOClient
typealias SocketIOClientConfiguration = MockSocketIOClientConfiguration
typealias SocketIOClientOption = MockSocketIOClientOption