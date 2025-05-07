import Foundation

protocol TechnicianEvent: AnalyticsEvent {}

extension TechnicianEvent {
    var category: String {
        return EventCategory.technician.rawValue
    }
}

// 작업 수락 이벤트
struct JobAcceptedEvent: TechnicianEvent {
    let jobId: String
    let acceptanceTime: TimeInterval
    
    var name: String {
        return "job_accepted"
    }
    
    var parameters: [String: Any] {
        return [
            "job_id": jobId,
            "acceptance_time": acceptanceTime,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 작업 시작 이벤트
struct JobStartedEvent: TechnicianEvent {
    let jobId: String
    let onTime: Bool
    let delay: TimeInterval?
    
    var name: String {
        return "job_started"
    }
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "job_id": jobId,
            "on_time": onTime,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let delay = delay {
            params["delay"] = delay
        }
        
        return params
    }
}

// 작업 완료 이벤트
struct JobCompletedEvent: TechnicianEvent {
    let jobId: String
    let duration: TimeInterval
    let photosUploaded: Int
    
    var name: String {
        return "job_completed"
    }
    
    var parameters: [String: Any] {
        return [
            "job_id": jobId,
            "duration": duration,
            "photos_uploaded": photosUploaded,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// 일정 업데이트 이벤트
struct ScheduleUpdatedEvent: TechnicianEvent {
    let availableDays: [Int]
    let availableTimeSlots: Int
    
    var name: String {
        return "schedule_updated"
    }
    
    var parameters: [String: Any] {
        return [
            "available_days": availableDays,
            "available_time_slots": availableTimeSlots,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}