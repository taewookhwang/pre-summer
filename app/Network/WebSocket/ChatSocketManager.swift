// 의존성
import Foundation

class ChatSocketManager {
    static let shared = ChatSocketManager()
    
    private let webSocketManager = WebSocketManager.shared
    private var isConnected = false
    
    // Callback handlers
    var onReceiveMessage: ((Message) -> Void)?
    var onUserTyping: ((String) -> Void)?
    var onUserOnlineStatusChange: ((String, Bool) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    // Message cache
    private let messageCache = MessageCache.shared
    
    private init() {
        // Setup WebSocket event handlers
        setupWebSocketHandlers()
    }
    
    private func setupWebSocketHandlers() {
        webSocketManager.onStringMessage = { [weak self] message in
            self?.handleIncomingMessage(message)
        }
        
        webSocketManager.onConnect = { [weak self] in
            self?.isConnected = true
            self?.onConnect?()
        }
        
        webSocketManager.onDisconnect = { [weak self] error in
            self?.isConnected = false
            self?.onDisconnect?(error)
        }
    }
    
    // Connect to chat room
    func connectToRoom(roomId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isConnected else {
            completion(.success(()))
            return
        }
        
        // In a real app, would use a real WebSocket URL
        // let url = URL(string: "wss://api.example.com/chat/\(roomId)?userId=\(userId)")!
        // let headers = ["Authorization": "Bearer \(AuthService.shared.getToken() ?? "")"]
        
        // webSocketManager.connect(url: url, headers: headers, completion: completion)
        
        // Dummy implementation for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isConnected = true
            self.onConnect?()
            completion(.success(()))
            
            // Simulate receiving messages for testing
            self.simulateIncomingMessages(roomId: roomId)
        }
    }
    
    // Disconnect from chat room
    func disconnect() {
        webSocketManager.disconnect()
        isConnected = false
    }
    
    // Send a message
    func sendMessage(roomId: String, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            let error = NSError(domain: "ChatSocketManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not connected to the server."])
            completion(.failure(error))
            return
        }
        
        // Convert message to JSON format
        var messageDict: [String: Any] = [
            "id": message.id,
            "roomId": roomId,
            "senderId": message.senderId,
            "content": message.content,
            "type": message.type.rawValue,
            "timestamp": Int(message.timestamp.timeIntervalSince1970 * 1000)
        ]
        
        if let attachmentURL = message.attachmentURL {
            messageDict["attachmentURL"] = attachmentURL
        }
        
        do {
            // 변수를 사용하지 않으므로 언더스코어로 대체
            _ = try JSONSerialization.data(withJSONObject: messageDict)
            
            // Would actually send via WebSocket
            // webSocketManager.send(message: jsonData) { result in
            //     completion(result)
            // }
            
            // Dummy implementation: Add message with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Add to local cache
                self.messageCache.addMessage(roomId: roomId, message: message)
                completion(.success(()))
                
                // Simulate echo response (for testing to show the message was received)
                if message.type == .text {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.simulateEchoMessage(roomId: roomId, originalMessage: message)
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Send user typing status
    func sendTypingStatus(roomId: String, isTyping: Bool) {
        guard isConnected else { return }
        
        // UserRepository를 사용하여 현재 사용자 ID 가져오기 
        let currentUser = UserRepository.shared.getCurrentUser()
        let userId = currentUser?.id.description ?? "unknown"
        
        let statusDict: [String: Any] = [
            "type": "typing",
            "roomId": roomId,
            "userId": userId,
            "isTyping": isTyping
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: statusDict)
            webSocketManager.send(message: jsonData) { _ in }
        } catch {
            print("Error sending typing status: \(error)")
        }
    }
    
    // Process incoming message
    private func handleIncomingMessage(_ messageString: String) {
        guard let data = messageString.data(using: .utf8) else { return }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else { return }
            
            switch type {
            case "message":
                handleChatMessage(json)
            case "typing":
                handleTypingStatus(json)
            case "status":
                handleUserStatus(json)
            default:
                break
            }
        } catch {
            print("Error parsing message: \(error)")
        }
    }
    
    private func handleChatMessage(_ json: [String: Any]) {
        guard let roomId = json["roomId"] as? String,
              let messageId = json["id"] as? String,
              let senderId = json["senderId"] as? String,
              let content = json["content"] as? String,
              let messageTypeRaw = json["type"] as? String,
              let timestampMs = json["timestamp"] as? TimeInterval else { return }
        
        let messageType: Message.MessageType = Message.MessageType(rawValue: messageTypeRaw) ?? .text
        let attachmentURL = json["attachmentURL"] as? String
        
        let timestamp = Date(timeIntervalSince1970: timestampMs / 1000)
        
        let message = Message(
            id: messageId,
            senderId: senderId,
            content: content,
            type: messageType,
            timestamp: timestamp,
            attachmentURL: attachmentURL
        )
        
        // Add to message cache
        messageCache.addMessage(roomId: roomId, message: message)
        
        // Trigger callback
        onReceiveMessage?(message)
    }
    
    private func handleTypingStatus(_ json: [String: Any]) {
        guard let userId = json["userId"] as? String,
              let isTyping = json["isTyping"] as? Bool else { return }
        
        if isTyping {
            onUserTyping?(userId)
        }
    }
    
    private func handleUserStatus(_ json: [String: Any]) {
        guard let userId = json["userId"] as? String,
              let isOnline = json["isOnline"] as? Bool else { return }
        
        onUserOnlineStatusChange?(userId, isOnline)
    }
    
    // MARK: - Dummy Test Implementations
    
    private func simulateIncomingMessages(roomId: String) {
        let recipientId = "user_123" // Dummy user ID
        
        // Send first message after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let message = Message(
                id: UUID().uuidString,
                senderId: recipientId,
                content: "Hello! How can I help you today?",
                type: .text,
                timestamp: Date(),
                attachmentURL: nil
            )
            
            self.messageCache.addMessage(roomId: roomId, message: message)
            self.onReceiveMessage?(message)
            
            // Send second message after 2 more seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let message2 = Message(
                    id: UUID().uuidString,
                    senderId: recipientId,
                    content: "Do you have any questions about your booking?",
                    type: .text,
                    timestamp: Date(),
                    attachmentURL: nil
                )
                
                self.messageCache.addMessage(roomId: roomId, message: message2)
                self.onReceiveMessage?(message2)
                
                // Simulate typing indicator
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.onUserTyping?(recipientId)
                }
            }
        }
    }
    
    private func simulateEchoMessage(roomId: String, originalMessage: Message) {
        let recipientId = "user_123" // Dummy user ID
        
        let response = Message(
            id: UUID().uuidString,
            senderId: recipientId,
            content: "I received your message. Thank you!",
            type: .text,
            timestamp: Date(),
            attachmentURL: nil
        )
        
        self.messageCache.addMessage(roomId: roomId, message: response)
        self.onReceiveMessage?(response)
    }
}