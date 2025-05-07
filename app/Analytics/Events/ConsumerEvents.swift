import Foundation

protocol ConsumerEvent: AnalyticsEvent {}

extension ConsumerEvent {
    var category: String {
        return EventCategory.consumer.rawValue
    }
}

// 서비스 검색 이벤트
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
            "filter_applied": filterApplied,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 서비스 조회 이벤트
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
            "view_duration": viewDuration,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 예약 생성 이벤트
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
        return [
            "reservation_id": reservationId,
            "service_id": serviceId,
            "service_name": serviceName,
            "price": price,
            "scheduled_date": scheduledDate.timeIntervalSince1970,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 예약 취소 이벤트
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
            "time_before_scheduled": timeBeforeScheduled,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let reason = reason {
            params["reason"] = reason
        }
        
        return params
    }
}

// 리뷰 제출 이벤트
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
            "has_comment": hasComment,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}