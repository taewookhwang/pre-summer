import Foundation

class ChatListViewModel {
    // 의존성
    private let chatService = ChatService.shared
    
    // 상태
    private(set) var chatRooms: [String] = []
    private(set) var isLoading = false
    
    // 콜백
    var onRoomsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init() {
        // 초기 채팅방 목록 로드
        loadChatRooms()
    }
    
    // 채팅방 목록 로드
    func loadChatRooms() {
        isLoading = true
        
        // 비동기 작업 시뮬레이션 (실제 구현에서는 네트워크 호출 등이 있을 수 있음)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // 채팅방 목록 가져오기
            let rooms = self.chatService.getChatRooms()
            
            // 메인 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                self.chatRooms = rooms
                self.isLoading = false
                self.onRoomsUpdated?()
                
                // 채팅방이 없으면 테스트용 더미 데이터 추가
                if self.chatRooms.isEmpty {
                    self.addDummyChatRooms()
                }
            }
        }
    }
    
    // 테스트용 더미 채팅방 추가
    private func addDummyChatRooms() {
        let dummyRooms = [
            "room_support",
            "room_booking_123",
            "room_feedback_456"
        ]
        
        self.chatRooms = dummyRooms
        
        // 저장
        _ = ChatRepository.shared.saveChatRooms(dummyRooms)
        
        self.onRoomsUpdated?()
    }
    
    // 특정 채팅방의 최근 메시지 가져오기
    func getLatestMessage(forRoomId roomId: String) -> Message? {
        let messages = chatService.getLatestMessages(roomId: roomId, limit: 1)
        return messages.first
    }
    
    // 채팅방 이름 표시용 (실제 구현에서는 상대방 이름 등을 표시)
    func getRoomDisplayName(roomId: String) -> String {
        if roomId.starts(with: "room_support") {
            return "고객 지원"
        } else if roomId.starts(with: "room_booking") {
            return "예약 문의"
        } else if roomId.starts(with: "room_feedback") {
            return "서비스 피드백"
        } else {
            return "채팅 \(roomId.suffix(4))"
        }
    }
    
    // 새 채팅방 생성 (미구현 - 필요시 확장)
    func createNewChatRoom(withUserId userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 새 채팅방 ID 생성
        let newRoomId = "room_\(UUID().uuidString.prefix(8))"
        
        // 채팅방 목록에 추가하고 저장
        var updatedRooms = chatRooms
        updatedRooms.append(newRoomId)
        
        if ChatRepository.shared.saveChatRooms(updatedRooms) {
            self.chatRooms = updatedRooms
            self.onRoomsUpdated?()
            completion(.success(newRoomId))
        } else {
            let error = NSError(domain: "ChatListViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "채팅방을 생성할 수 없습니다."])
            completion(.failure(error))
        }
    }
}