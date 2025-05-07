import Foundation

protocol WebSocketProtocol {
    var isConnected: Bool { get }
    
    func connect(url: URL, headers: [String: String]?, completion: @escaping (Result<Void, Error>) -> Void)
    func disconnect()
    func send(message: Data, completion: @escaping (Result<Void, Error>) -> Void)
    func send(message: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    var onMessage: ((Data) -> Void)? { get set }
    var onStringMessage: ((String) -> Void)? { get set }
    var onConnect: (() -> Void)? { get set }
    var onDisconnect: ((Error?) -> Void)? { get set }
}