import Foundation

protocol BusinessEvent: AnalyticsEvent {}

extension BusinessEvent {
    var category: String {
        return EventCategory.business.rawValue
    }
}

// 서비스 추가 이벤트
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
            "price": price,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 서비스 업데이트 이벤트
struct ServiceUpdatedEvent: BusinessEvent {
    let serviceId: String
    let updatedFields: [String]
    
    var name: String {
        return "service_updated"
    }
    
    var parameters: [String: Any] {
        return [
            "service_id": serviceId,
            "updated_fields": updatedFields,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 가격 변경 이벤트
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
            "change_percent": calculateChangePercent(),
            "timestamp": Date().timeIntervalSince1970
        ]
    }
    
    private func calculateChangePercent() -> Double {
        guard oldPrice > 0 else { return 100.0 }
        return ((newPrice - oldPrice) / oldPrice) * 100.0
    }
}

// 시스템 이벤트 예시 (필요시 System 카테고리 추가 가능)
struct SystemEvent: AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    var category: String {
        return EventCategory.system.rawValue
    }
}