import Foundation

class ChatRepository {
    static let shared = ChatRepository()
    
    // 의존성
    private let databaseManager = DatabaseManager.shared
    private let chatSocketManager = ChatSocketManager.shared
    private let messageCache = MessageCache.shared
    
    // 키
    private let chatRoomsKey = "chat_rooms"
    
    private init() {}
    
    // 채팅방 목록 저장
    func saveChatRooms(_ rooms: [String]) -> Bool {
        return databaseManager.save(rooms, forKey: chatRoomsKey)
    }
    
    // 채팅방 목록 가져오기
    func getChatRooms() -> [String] {
        return databaseManager.load(forKey: chatRoomsKey) ?? []
    }
    
    // 특정 채팅방 메시지 가져오기
    func getMessages(roomId: String) -> [Message] {
        return messageCache.getMessages(roomId: roomId)
    }
    
    // 특정 채팅방 최신 메시지 가져오기
    func getLatestMessages(roomId: String, limit: Int = 20) -> [Message] {
        return messageCache.getLatestMessages(roomId: roomId, limit: limit)
    }
    
    // 메시지 전송
    func sendMessage(roomId: String, content: String, type: Message.MessageType = .text, attachmentURL: String? = nil, completion: @escaping (Result<Message, Error>) -> Void) {
        // 현재 사용자 확인
        guard let currentUser = UserRepository.shared.getCurrentUser() else {
            let error = NSError(domain: "ChatRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])
            completion(.failure(error))
            return
        }
        
        // 새 메시지 생성
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUser.id.description,
            content: content,
            type: type,
            timestamp: Date(),
            attachmentURL: attachmentURL
        )
        
        // 소켓을 통해 메시지 전송
        chatSocketManager.sendMessage(roomId: roomId, message: message) { result in
            switch result {
            case .success:
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 채팅방 연결
    func connectToRoom(roomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = UserRepository.shared.getCurrentUser() else {
            let error = NSError(domain: "ChatRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])
            completion(.failure(error))
            return
        }
        
        chatSocketManager.connectToRoom(roomId: roomId, userId: currentUser.id.description, completion: completion)
    }
    
    // 채팅방 연결 해제
    func disconnectFromRoom() {
        chatSocketManager.disconnect()
    }
    
    // 타이핑 상태 전송
    func sendTypingStatus(roomId: String, isTyping: Bool) {
        chatSocketManager.sendTypingStatus(roomId: roomId, isTyping: isTyping)
    }
}