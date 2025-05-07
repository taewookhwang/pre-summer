import Foundation

protocol TechnicianEvent: AnalyticsEvent {}

extension TechnicianEvent {
    var category: String {
        return EventCategory.technician.rawValue
    }
}

struct JobAcceptedEvent: TechnicianEvent {
    let jobId: String
    let acceptanceTime: TimeInterval
    
    var name: String {
        return "job_accepted"
    }
    
    var parameters: [String: Any] {
        return [
            "job_id": jobId,
            "acceptance_time": acceptanceTime
        ]
    }
}

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
            "on_time": onTime
        ]
        
        if let delay = delay {
            params["delay"] = delay
        }
        
        return params
    }
}

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
            "photos_uploaded": photosUploaded
        ]
    }
}

struct ScheduleUpdatedEvent: TechnicianEvent {
    let availableDays: [Int]
    let availableTimeSlots: Int
    
    var name: String {
        return "schedule_updated"
    }
    
    var parameters: [String: Any] {
        return [
            "available_days": availableDays,
            "available_time_slots": availableTimeSlots
        ]
    }
}