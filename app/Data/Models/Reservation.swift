import Foundation
import UIKit

struct Reservation: Codable {
    let id: String
    let userId: Int
    let serviceId: String
    let technicianId: Int?
    let scheduledTime: Date
    let status: ReservationStatus
    let address: AddressObject
    let specialInstructions: String?
    let serviceOptions: [String]?
    let customFields: [String: String]?
    let estimatedPrice: String
    let estimatedDuration: Int
    let paymentStatus: String
    let currentStep: String?
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
        case scheduledTime = "scheduled_time"
        case status
        case address
        case specialInstructions = "special_instructions"
        case serviceOptions = "service_options"
        case customFields = "custom_fields"
        case estimatedPrice = "estimated_price"
        case estimatedDuration = "estimated_duration"
        case paymentStatus = "payment_status"
        case currentStep = "current_step"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case service, technician, payment
    }
    
    // Computed properties for compatibility with existing code
    var totalPrice: String {
        return estimatedPrice
    }
    
    var reservationDate: Date {
        return scheduledTime
    }
    
    var dateTime: Date {
        return scheduledTime
    }

    // Standard initializer for creating instances
    init(id: String, userId: Int, serviceId: String, technicianId: Int?, scheduledTime: Date,
         status: ReservationStatus, address: AddressObject, specialInstructions: String?,
         serviceOptions: [String]? = nil, customFields: [String: String]? = nil,
         estimatedPrice: String, estimatedDuration: Int, paymentStatus: String,
         currentStep: String? = nil, createdAt: Date, updatedAt: Date,
         service: Service? = nil, technician: AppUser? = nil, payment: Payment? = nil) {
        self.id = id
        self.userId = userId
        self.serviceId = serviceId
        self.technicianId = technicianId
        self.scheduledTime = scheduledTime
        self.status = status
        self.address = address
        self.specialInstructions = specialInstructions
        self.serviceOptions = serviceOptions
        self.customFields = customFields
        self.estimatedPrice = estimatedPrice
        self.estimatedDuration = estimatedDuration
        self.paymentStatus = paymentStatus
        self.currentStep = currentStep
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.service = service
        self.technician = technician
        self.payment = payment
    }

    // Helper initializer for compatibility with legacy code
    init(legacyId: String, userId: Int, serviceId: String, technicianId: Int?, reservationDate: Date,
         status: ReservationStatus, addressString: String, specialInstructions: String?, totalPrice: String,
         paymentStatus: String, createdAt: Date, updatedAt: Date,
         service: Service? = nil, technician: AppUser? = nil, payment: Payment? = nil) {
        self.id = legacyId
        self.userId = userId
        self.serviceId = serviceId
        self.technicianId = technicianId
        self.scheduledTime = reservationDate
        self.status = status
        self.address = AddressObject(street: addressString, detail: nil, postalCode: nil, coordinates: nil)
        self.specialInstructions = specialInstructions
        self.serviceOptions = nil
        self.customFields = nil
        self.estimatedPrice = totalPrice
        self.estimatedDuration = 0 // 기본값
        self.paymentStatus = paymentStatus
        self.currentStep = nil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.service = service
        self.technician = technician
        self.payment = payment
    }
}

// 주소 객체 모델 (백엔드에서 반환하는 형식과 일치)
struct AddressObject: Codable {
    let street: String
    let detail: String?
    let postalCode: String?
    let coordinates: Coordinates?

    enum CodingKeys: String, CodingKey {
        case street
        case detail
        case postalCode = "postal_code"
        case coordinates
    }

    init(street: String, detail: String? = nil, postalCode: String? = nil, coordinates: Coordinates? = nil) {
        self.street = street
        self.detail = detail
        self.postalCode = postalCode
        self.coordinates = coordinates
    }
}

// 좌표 모델
struct Coordinates: Codable {
    let latitude: Double?
    let longitude: Double?

    init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

enum ReservationStatus: String, Codable {
    case pending = "pending"
    case searchingTechnician = "searching_technician"
    case technicianAssigned = "technician_assigned"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .searchingTechnician:
            return "Finding Technician"
        case .technicianAssigned:
            return "Technician Assigned"
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
        case .pending, .searchingTechnician:
            return .systemYellow
        case .technicianAssigned:
            return .systemBlue
        case .inProgress:
            return .systemGreen
        case .completed:
            return .systemGray
        case .cancelled:
            return .systemRed
        }
    }
}

struct ReservationRequest: Codable {
    let serviceId: String
    let dateTime: Date
    let address: String  // We'll format this as an object when sending to API
    let specialInstructions: String?

    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case dateTime = "scheduled_time"  // Update to use scheduled_time
        case address
        case specialInstructions = "special_instructions"
    }

    // Create address object for API requests
    // Swagger API 명세에 맞게 주소 객체 형식 업데이트
    func formatAddressObject() -> [String: Any] {
        let components = address.components(separatedBy: " ")
        let detailPart = components.count > 3 ? components.suffix(from: 3).joined(separator: " ") : ""

        return [
            "street": address,          // 필수 필드
            "detail": detailPart,       // 선택적 필드
            "postal_code": ""           // 선택적 필드
        ]
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

// API Response 구조체는 Network/APIs/Consumer/ServiceHistoryAPI.swift에 정의되어 있음