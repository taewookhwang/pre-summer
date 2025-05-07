import Foundation

class MessageCache {
    static let shared = MessageCache()
    
    // Messages dictionary keyed by room ID
    private var messagesByRoom: [String: [Message]] = [:]
    
    // Thread safety queue
    private let queue = DispatchQueue(label: "com.homecleaning.messageCache", attributes: .concurrent)
    
    private init() {}
    
    // Get all messages for a room
    func getMessages(roomId: String) -> [Message] {
        var messages: [Message] = []
        
        queue.sync {
            messages = messagesByRoom[roomId] ?? []
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    // Add a single message
    func addMessage(roomId: String, message: Message) {
        queue.async(flags: .barrier) {
            if self.messagesByRoom[roomId] == nil {
                self.messagesByRoom[roomId] = []
            }
            
            // Only add if not a duplicate
            if !self.messagesByRoom[roomId]!.contains(where: { $0.id == message.id }) {
                self.messagesByRoom[roomId]!.append(message)
            }
        }
    }
    
    // Add multiple messages
    func addMessages(roomId: String, messages: [Message]) {
        queue.async(flags: .barrier) {
            if self.messagesByRoom[roomId] == nil {
                self.messagesByRoom[roomId] = []
            }
            
            // Add each message that doesn't already exist
            for message in messages {
                if !self.messagesByRoom[roomId]!.contains(where: { $0.id == message.id }) {
                    self.messagesByRoom[roomId]!.append(message)
                }
            }
        }
    }
    
    // Delete a specific message
    func deleteMessage(roomId: String, messageId: String) {
        queue.async(flags: .barrier) {
            self.messagesByRoom[roomId]?.removeAll { $0.id == messageId }
        }
    }
    
    // Clear all messages for a room
    func clearRoom(roomId: String) {
        queue.async(flags: .barrier) {
            self.messagesByRoom[roomId] = []
        }
    }
    
    // Clear all messages
    func clearAll() {
        queue.async(flags: .barrier) {
            self.messagesByRoom = [:]
        }
    }
    
    // Get messages since a particular timestamp
    func getMessagesSince(roomId: String, timestamp: Date) -> [Message] {
        var messages: [Message] = []
        
        queue.sync {
            let allMessages = self.messagesByRoom[roomId] ?? []
            messages = allMessages.filter { $0.timestamp > timestamp }
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    // Get the most recent messages (limited by count)
    func getLatestMessages(roomId: String, limit: Int) -> [Message] {
        var messages: [Message] = []
        
        queue.sync {
            let allMessages = self.messagesByRoom[roomId] ?? []
            let sortedMessages = allMessages.sorted { $0.timestamp > $1.timestamp }
            messages = Array(sortedMessages.prefix(limit))
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    // Get messages before a specific message ID (for pagination)
    func getMessagesBefore(roomId: String, messageId: String, limit: Int) -> [Message] {
        var messages: [Message] = []
        
        queue.sync {
            let allMessages = self.messagesByRoom[roomId] ?? []
            let sortedMessages = allMessages.sorted { $0.timestamp < $1.timestamp }
            
            if let index = sortedMessages.firstIndex(where: { $0.id == messageId }), index > 0 {
                let startIndex = max(0, index - limit)
                messages = Array(sortedMessages[startIndex..<index])
            }
        }
        
        return messages
    }
}