import Foundation
// import Starscream

class WebSocketManager: WebSocketProtocol {
    static let shared = WebSocketManager()
    
    private init() {}
    
    // Starscream WebSocket 구현 (현재는 주석 처리)
    // private var socket: WebSocket?
    private var isConnectedValue = false
    
    // WebSocket 콜백
    var onMessage: ((Data) -> Void)?
    var onStringMessage: ((String) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    var isConnected: Bool {
        return isConnectedValue
    }
    
    func connect(url: URL, headers: [String: String]? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        // Starscream WebSocket 연결 (현재는 주석 처리)
        // var request = URLRequest(url: url)
        // if let headers = headers {
        //     for (key, value) in headers {
        //         request.setValue(value, forHTTPHeaderField: key)
        //     }
        // }
        
        // socket = WebSocket(request: request)
        // socket?.delegate = self
        // socket?.connect()
        
        // 더미 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isConnectedValue = true
            self.onConnect?()
            completion(.success(()))
        }
    }
    
    func disconnect() {
        // socket?.disconnect()
        
        // 더미 구현
        isConnectedValue = false
        onDisconnect?(nil)
    }
    
    func send(message: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        // socket?.write(data: message)
        
        // 더미 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(.success(()))
        }
    }
    
    func send(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // socket?.write(string: message)
        
        // 더미 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(.success(()))
        }
    }
}

// MARK: - WebSocketDelegate

// Starscream WebSocketDelegate 구현 (현재는 주석 처리)
// extension WebSocketManager: WebSocketDelegate {
//     func didReceive(event: WebSocketEvent, client: WebSocket) {
//         switch event {
//         case .connected(let headers):
//             isConnectedValue = true
//             onConnect?()
//         case .disconnected(let reason, let code):
//             isConnectedValue = false
//             let error = NSError(domain: "WebSocketManager", code: Int(code), userInfo: [NSLocalizedDescriptionKey: reason])
//             onDisconnect?(error)
//         case .text(let string):
//             onStringMessage?(string)
//         case .binary(let data):
//             onMessage?(data)
//         case .error(let error):
//             onDisconnect?(error)
//         default:
//             break
//         }
//     }
// }