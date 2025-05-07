import Foundation

protocol BusinessEvent: AnalyticsEvent {}

extension BusinessEvent {
    var category: String {
        return EventCategory.business.rawValue
    }
}

struct ServiceAddedEvent: BusinessEvent {
    let serviceId: String
    let serviceName: String
    let serviceCategory: String
    let price: Double
    
    var name: String {
        return "service_added"
    }
    
    var parameters: [String: Any] {
        return [
            "service_id": serviceId,
            "service_name": serviceName,
            "service_category": serviceCategory,
            "price": price
        ]
    }
}

struct ServiceUpdatedEvent: BusinessEvent {
    let serviceId: String
    let updatedFields: [String]
    
    var name: String {
        return "service_updated"
    }
    
    var parameters: [String: Any] {
        return [
            "service_id": serviceId,
            "updated_fields": updatedFields
        ]
    }
}

struct PriceChangedEvent: BusinessEvent {
    let serviceId: String
    let serviceName: String
    let oldPrice: Double
    let newPrice: Double
    
    var name: String {
        return "price_changed"
    }
    
    var parameters: [String: Any] {
        return [
            "service_id": serviceId,
            "service_name": serviceName,
            "old_price": oldPrice,
            "new_price": newPrice,
            "change_percent": ((newPrice - oldPrice) / oldPrice) * 100
        ]
    }
}