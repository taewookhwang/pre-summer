import Foundation

class ChatRoomViewModel {
    // 의존성
    private let chatService = ChatService.shared
    private let userRepository = UserRepository.shared
    
    // 상태
    private(set) var roomId: String
    private(set) var messages: [Message] = []
    private(set) var isConnected = false
    private(set) var isLoading = false
    
    // 콜백
    var onMessagesUpdated: (() -> Void)?
    var onConnectionStatusChanged: ((Bool) -> Void)?
    var onUserTyping: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    init(roomId: String) {
        self.roomId = roomId
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        // ChatService의 콜백 설정
        chatService.onReceiveMessage = { [weak self] message in
            guard let self = self else { return }
            
            // 이미 메시지 목록에 있는지 확인
            if !self.messages.contains(where: { $0.id == message.id }) {
                self.messages.append(message)
                
                // 메시지를 시간순으로 정렬
                self.messages.sort { $0.timestamp < $1.timestamp }
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.onMessagesUpdated?()
                }
            }
        }
        
        chatService.onUserTyping = { [weak self] userId in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.onUserTyping?(userId)
            }
        }
        
        chatService.onConnect = { [weak self] in
            guard let self = self else { return }
            
            self.isConnected = true
            
            DispatchQueue.main.async {
                self.onConnectionStatusChanged?(true)
            }
        }
        
        chatService.onDisconnect = { [weak self] error in
            guard let self = self else { return }
            
            self.isConnected = false
            
            DispatchQueue.main.async {
                self.onConnectionStatusChanged?(false)
                
                if let error = error {
                    self.onError?(error)
                }
            }
        }
    }
    
    // 채팅방 연결 메서드
    func connectToRoom(completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        
        chatService.connectToRoom(roomId: roomId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success:
                // 기존 메시지 로드
                self.loadMessages()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 채팅방 연결 해제
    func disconnect() {
        chatService.disconnectFromRoom()
        isConnected = false
        onConnectionStatusChanged?(false)
    }
    
    // 메시지 로드
    func loadMessages() {
        isLoading = true
        
        // 메시지 가져오기 (캐시된 메시지)
        let cachedMessages = chatService.getMessages(roomId: roomId)
        
        self.messages = cachedMessages.sorted { $0.timestamp < $1.timestamp }
        self.isLoading = false
        self.onMessagesUpdated?()
    }
    
    // 메시지 전송
    func sendMessage(content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let error = NSError(domain: "ChatRoomViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "메시지 내용이 비어있습니다."])
            completion(.failure(error))
            return
        }
        
        chatService.sendMessage(roomId: roomId, content: content) { [weak self] result in
            switch result {
            case .success(let message):
                // 이미 ChatService의 콜백에서 메시지를 추가하므로 여기서는 생략
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 타이핑 상태 전송
    func sendTypingStatus(isTyping: Bool) {
        chatService.sendTypingStatus(roomId: roomId, isTyping: isTyping)
    }
    
    // 이미지 메시지 전송
    func sendImageMessage(imageData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        chatService.sendImageMessage(roomId: roomId, imageData: imageData) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 위치 메시지 전송
    func sendLocationMessage(latitude: Double, longitude: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        chatService.sendLocationMessage(roomId: roomId, latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 음성 메시지 전송
    func sendVoiceMessage(audioData: Data, duration: TimeInterval, completion: @escaping (Result<Void, Error>) -> Void) {
        chatService.sendVoiceMessage(roomId: roomId, audioData: audioData, duration: duration) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 현재 사용자 ID 가져오기
    func getCurrentUserId() -> String? {
        return userRepository.getCurrentUser()?.id.description
    }
    
    // 메시지가 현재 사용자의 것인지 확인
    func isMessageFromCurrentUser(message: Message) -> Bool {
        guard let currentUserId = getCurrentUserId() else {
            return false
        }
        
        return message.senderId == currentUserId
    }
}