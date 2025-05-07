import Foundation
import UIKit

struct Job: Codable {
    let id: String
    let reservationId: String
    let technicianId: Int
    let status: JobStatus
    let startTime: Date?
    let endTime: Date?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Relationship models (included in API response if available)
    var reservation: Reservation?
    var technician: AppUser?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reservationId = "reservation_id"
        case technicianId = "technician_id"
        case status
        case startTime = "start_time"
        case endTime = "end_time"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case reservation, technician
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        reservationId = try container.decode(String.self, forKey: .reservationId)
        technicianId = try container.decode(Int.self, forKey: .technicianId)
        status = try container.decode(JobStatus.self, forKey: .status)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Optional relationships - need to handle as they might not be in the response
        reservation = try container.decodeIfPresent(Reservation.self, forKey: .reservation)
        
        // Handle the User type specifically to avoid ambiguity
        if container.contains(.technician) {
            technician = try container.decode(AppUser.self, forKey: .technician)
        } else {
            technician = nil
        }
    }
    
    // Explicitly implement Encodable function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(reservationId, forKey: .reservationId)
        try container.encode(technicianId, forKey: .technicianId)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode relationships
        try container.encodeIfPresent(reservation, forKey: .reservation)
        try container.encodeIfPresent(technician, forKey: .technician)
    }
    
    // Standard initializer for creating instances
    init(id: String, reservationId: String, technicianId: Int, status: JobStatus,
         startTime: Date? = nil, endTime: Date? = nil, notes: String? = nil,
         createdAt: Date, updatedAt: Date,
         reservation: Reservation? = nil, technician: AppUser? = nil) {
        self.id = id
        self.reservationId = reservationId
        self.technicianId = technicianId
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reservation = reservation
        self.technician = technician
    }
}

enum JobStatus: String, Codable {
    case assigned = "assigned"
    case accepted = "accepted"
    case onWay = "on_way"
    case arrived = "arrived"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .assigned:
            return "Assigned"
        case .accepted:
            return "Accepted"
        case .onWay:
            return "On Way"
        case .arrived:
            return "Arrived"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var color: UIColor {
        switch self {
        case .assigned:
            return .systemGray
        case .accepted:
            return .systemBlue
        case .onWay:
            return .systemIndigo
        case .arrived:
            return .systemPurple
        case .inProgress:
            return .systemGreen
        case .completed:
            return .systemTeal
        case .cancelled:
            return .systemRed
        }
    }
}