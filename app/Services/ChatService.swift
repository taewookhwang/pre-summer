import Foundation

class ChatService {
    static let shared = ChatService()
    
    // 의존성
    private let chatRepository = ChatRepository.shared
    private let userRepository = UserRepository.shared
    
    // 콜백 핸들러
    var onReceiveMessage: ((Message) -> Void)?
    var onUserTyping: ((String) -> Void)?
    var onUserOnlineStatusChange: ((String, Bool) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    private init() {
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        // ChatSocketManager의 콜백을 ChatService로 연결
        let socketManager = ChatSocketManager.shared
        
        socketManager.onReceiveMessage = { [weak self] message in
            self?.onReceiveMessage?(message)
        }
        
        socketManager.onUserTyping = { [weak self] userId in
            self?.onUserTyping?(userId)
        }
        
        socketManager.onUserOnlineStatusChange = { [weak self] userId, isOnline in
            self?.onUserOnlineStatusChange?(userId, isOnline)
        }
        
        socketManager.onConnect = { [weak self] in
            self?.onConnect?()
        }
        
        socketManager.onDisconnect = { [weak self] error in
            self?.onDisconnect?(error)
        }
    }
    
    // 채팅방 목록 가져오기
    func getChatRooms() -> [String] {
        return chatRepository.getChatRooms()
    }
    
    // 채팅방의 메시지 가져오기
    func getMessages(roomId: String) -> [Message] {
        return chatRepository.getMessages(roomId: roomId)
    }
    
    // 채팅방의 최근 메시지 가져오기
    func getLatestMessages(roomId: String, limit: Int = 20) -> [Message] {
        return chatRepository.getLatestMessages(roomId: roomId, limit: limit)
    }
    
    // 채팅방 연결
    func connectToRoom(roomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        chatRepository.connectToRoom(roomId: roomId, completion: completion)
    }
    
    // 채팅방 연결 해제
    func disconnectFromRoom() {
        chatRepository.disconnectFromRoom()
    }
    
    // 메시지 전송
    func sendMessage(roomId: String, content: String, type: Message.MessageType = .text, attachmentURL: String? = nil, completion: @escaping (Result<Message, Error>) -> Void) {
        chatRepository.sendMessage(roomId: roomId, content: content, type: type, attachmentURL: attachmentURL, completion: completion)
    }
    
    // 타이핑 상태 전송
    func sendTypingStatus(roomId: String, isTyping: Bool) {
        chatRepository.sendTypingStatus(roomId: roomId, isTyping: isTyping)
    }
    
    // 이미지 메시지 전송
    func sendImageMessage(roomId: String, imageData: Data, completion: @escaping (Result<Message, Error>) -> Void) {
        // 실제 구현에서는 이미지를 업로드한 후 URL을 얻어 전송해야 함
        // 여기서는 더미 구현만 제공
        
        let tempAttachmentURL = "https://example.com/images/\(UUID().uuidString).jpg"
        
        chatRepository.sendMessage(
            roomId: roomId,
            content: "이미지를 보냈습니다.",
            type: .image,
            attachmentURL: tempAttachmentURL,
            completion: completion
        )
    }
    
    // 위치 메시지 전송
    func sendLocationMessage(roomId: String, latitude: Double, longitude: Double, completion: @escaping (Result<Message, Error>) -> Void) {
        // 위치 정보를 JSON 형식으로 변환
        let locationInfo: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationInfo)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                chatRepository.sendMessage(
                    roomId: roomId,
                    content: jsonString,
                    type: .location,
                    completion: completion
                )
            } else {
                let error = NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "위치 정보를 JSON 문자열로 변환할 수 없습니다."])
                completion(.failure(error))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // 음성 메시지 전송
    func sendVoiceMessage(roomId: String, audioData: Data, duration: TimeInterval, completion: @escaping (Result<Message, Error>) -> Void) {
        // 실제 구현에서는 오디오를 업로드한 후 URL을 얻어 전송해야 함
        // 여기서는 더미 구현만 제공
        
        let tempAttachmentURL = "https://example.com/audio/\(UUID().uuidString).m4a"
        let content = String(format: "음성 메시지 (%.1f초)", duration)
        
        chatRepository.sendMessage(
            roomId: roomId,
            content: content,
            type: .voice,
            attachmentURL: tempAttachmentURL,
            completion: completion
        )
    }
}