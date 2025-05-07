import Foundation

struct Message: Codable {
    let id: String
    let senderId: String
    let content: String
    let type: MessageType
    let timestamp: Date
    let attachmentURL: String?
    
    enum MessageType: String, Codable {
        case text
        case image
        case voice
        case location
    }
    
    init(id: String, senderId: String, content: String, type: MessageType, timestamp: Date, attachmentURL: String? = nil) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.attachmentURL = attachmentURL
    }
}