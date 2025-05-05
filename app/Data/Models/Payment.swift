import Foundation

struct Payment: Codable {
    let id: Int
    let reservationId: Int
    let amount: Double
    let status: PaymentStatus
    let method: PaymentMethod
    let transactionId: String?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case reservationId = "reservation_id"
        case amount
        case status
        case method
        case transactionId = "transaction_id"
        case timestamp
    }
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
    case cancelled = "cancelled"
}

enum PaymentMethod: String, Codable {
    case card = "card"
    case bankTransfer = "bank_transfer"
    case mobilePay = "mobile_pay"
    case virtualAccount = "virtual_account"
}