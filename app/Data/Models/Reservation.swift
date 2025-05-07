import Foundation
import UIKit

struct Reservation: Codable {
    let id: String
    let userId: Int
    let serviceId: String
    let technicianId: Int?
    let reservationDate: Date
    let status: ReservationStatus
    let address: String
    let specialInstructions: String?
    let totalPrice: String
    let paymentStatus: String
    let createdAt: Date
    let updatedAt: Date
    
    // Relationship models (included in API response if available)
    var service: Service?
    var technician: AppUser?
    var payment: Payment?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case serviceId = "service_id"
        case technicianId = "technician_id"
        case reservationDate = "reservation_date"
        case status
        case address
        case specialInstructions = "special_instructions"
        case totalPrice = "total_price"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case service, technician, payment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        serviceId = try container.decode(String.self, forKey: .serviceId)
        technicianId = try container.decodeIfPresent(Int.self, forKey: .technicianId)
        reservationDate = try container.decode(Date.self, forKey: .reservationDate)
        status = try container.decode(ReservationStatus.self, forKey: .status)
        address = try container.decode(String.self, forKey: .address)
        specialInstructions = try container.decodeIfPresent(String.self, forKey: .specialInstructions)
        totalPrice = try container.decode(String.self, forKey: .totalPrice)
        paymentStatus = try container.decode(String.self, forKey: .paymentStatus)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Optional relationships
        service = try container.decodeIfPresent(Service.self, forKey: .service)
        
        // Handle the User type specifically to avoid ambiguity
        if container.contains(.technician) {
            technician = try container.decode(AppUser.self, forKey: .technician)
        } else {
            technician = nil
        }
        
        payment = try container.decodeIfPresent(Payment.self, forKey: .payment)
    }
    
    // Explicitly implement Encodable function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(serviceId, forKey: .serviceId)
        try container.encodeIfPresent(technicianId, forKey: .technicianId)
        try container.encode(reservationDate, forKey: .reservationDate)
        try container.encode(status, forKey: .status)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(specialInstructions, forKey: .specialInstructions)
        try container.encode(totalPrice, forKey: .totalPrice)
        try container.encode(paymentStatus, forKey: .paymentStatus)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode relationships
        try container.encodeIfPresent(service, forKey: .service)
        try container.encodeIfPresent(technician, forKey: .technician)
        try container.encodeIfPresent(payment, forKey: .payment)
    }
    
    // Computed property to convert String price to Double
    var price: Double {
        return Double(totalPrice) ?? 0.0
    }
    
    // Computed property for dateTime compatibility
    var dateTime: Date {
        return reservationDate
    }
    
    // Standard initializer for creating instances
    init(id: String, userId: Int, serviceId: String, technicianId: Int?, reservationDate: Date, 
         status: ReservationStatus, address: String, specialInstructions: String?, totalPrice: String, 
         paymentStatus: String, createdAt: Date, updatedAt: Date, 
         service: Service? = nil, technician: AppUser? = nil, payment: Payment? = nil) {
        self.id = id
        self.userId = userId
        self.serviceId = serviceId
        self.technicianId = technicianId
        self.reservationDate = reservationDate
        self.status = status
        self.address = address
        self.specialInstructions = specialInstructions
        self.totalPrice = totalPrice
        self.paymentStatus = paymentStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.service = service
        self.technician = technician
        self.payment = payment
    }
}

enum ReservationStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        case .noShow:
            return "No Show"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending:
            return .systemYellow
        case .confirmed:
            return .systemBlue
        case .inProgress:
            return .systemGreen
        case .completed:
            return .systemGray
        case .cancelled:
            return .systemRed
        case .noShow:
            return .systemOrange
        }
    }
}

struct ReservationRequest: Codable {
    let serviceId: String
    let dateTime: Date
    let address: String
    let specialInstructions: String?
    
    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case dateTime = "date_time"
        case address
        case specialInstructions = "special_instructions"
    }
}

struct CancellationRequest: Codable {
    let reservationId: String
    let reason: String
    
    enum CodingKeys: String, CodingKey {
        case reservationId = "reservation_id"
        case reason
    }
}