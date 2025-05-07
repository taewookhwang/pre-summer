import Foundation

protocol ConsumerEvent: AnalyticsEvent {}

extension ConsumerEvent {
    var category: String {
        return EventCategory.consumer.rawValue
    }
}

struct ServiceSearchEvent: ConsumerEvent {
    let searchTerm: String
    let resultCount: Int
    let filterApplied: Bool
    
    var name: String {
        return "service_search"
    }
    
    var parameters: [String: Any] {
        return [
            "search_term": searchTerm,
            "result_count": resultCount,
            "filter_applied": filterApplied
        ]
    }
}

struct ServiceViewedEvent: ConsumerEvent {
    let serviceId: String
    let serviceName: String
    let viewDuration: TimeInterval
    
    var name: String {
        return "service_viewed"
    }
    
    var parameters: [String: Any] {
        return [
            "service_id": serviceId,
            "service_name": serviceName,
            "view_duration": viewDuration
        ]
    }
}

struct ReservationCreatedEvent: ConsumerEvent {
    let reservationId: String
    let serviceId: String
    let serviceName: String
    let price: Double
    let scheduledDate: Date
    
    var name: String {
        return "reservation_created"
    }
    
    var parameters: [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return [
            "reservation_id": reservationId,
            "service_id": serviceId,
            "service_name": serviceName,
            "price": price,
            "scheduled_date": dateFormatter.string(from: scheduledDate)
        ]
    }
}

struct ReservationCancelledEvent: ConsumerEvent {
    let reservationId: String
    let reason: String?
    let timeBeforeScheduled: TimeInterval
    
    var name: String {
        return "reservation_cancelled"
    }
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "reservation_id": reservationId,
            "time_before_scheduled": timeBeforeScheduled
        ]
        
        if let reason = reason {
            params["reason"] = reason
        }
        
        return params
    }
}

struct ReviewSubmittedEvent: ConsumerEvent {
    let reservationId: String
    let serviceId: String
    let rating: Int
    let hasComment: Bool
    
    var name: String {
        return "review_submitted"
    }
    
    var parameters: [String: Any] {
        return [
            "reservation_id": reservationId,
            "service_id": serviceId,
            "rating": rating,
            "has_comment": hasComment
        ]
    }
}