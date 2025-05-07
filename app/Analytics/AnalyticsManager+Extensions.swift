import Foundation

// This file provides convenience extensions for AnalyticsManager
// to make it easier to log common events

extension AnalyticsManager {
    
    // MARK: - Consumer Events
    
    static func logServiceSearch(term: String, resultCount: Int, filtered: Bool) {
        let event = ServiceSearchEvent(
            searchTerm: term,
            resultCount: resultCount,
            filterApplied: filtered
        )
        trackConsumerEvent(event)
    }
    
    static func logServiceViewed(id: String, name: String, duration: TimeInterval) {
        let event = ServiceViewedEvent(
            serviceId: id,
            serviceName: name,
            viewDuration: duration
        )
        trackConsumerEvent(event)
    }
    
    static func logReservationCreated(
        id: String,
        serviceId: String,
        serviceName: String,
        price: Double,
        date: Date
    ) {
        let event = ReservationCreatedEvent(
            reservationId: id,
            serviceId: serviceId,
            serviceName: serviceName,
            price: price,
            scheduledDate: date
        )
        trackConsumerEvent(event)
    }
    
    static func logReservationCancelled(
        id: String,
        reason: String?,
        timeBeforeScheduled: TimeInterval
    ) {
        let event = ReservationCancelledEvent(
            reservationId: id,
            reason: reason,
            timeBeforeScheduled: timeBeforeScheduled
        )
        trackConsumerEvent(event)
    }
    
    static func logReviewSubmitted(
        reservationId: String,
        serviceId: String,
        rating: Int,
        hasComment: Bool
    ) {
        let event = ReviewSubmittedEvent(
            reservationId: reservationId,
            serviceId: serviceId,
            rating: rating,
            hasComment: hasComment
        )
        trackConsumerEvent(event)
    }
    
    // MARK: - Technician Events
    
    static func logJobAccepted(jobId: String, acceptanceTime: TimeInterval) {
        let event = JobAcceptedEvent(
            jobId: jobId,
            acceptanceTime: acceptanceTime
        )
        trackTechnicianEvent(event)
    }
    
    static func logJobStarted(jobId: String, onTime: Bool, delay: TimeInterval? = nil) {
        let event = JobStartedEvent(
            jobId: jobId,
            onTime: onTime,
            delay: delay
        )
        trackTechnicianEvent(event)
    }
    
    static func logJobCompleted(jobId: String, duration: TimeInterval, photosUploaded: Int) {
        let event = JobCompletedEvent(
            jobId: jobId,
            duration: duration,
            photosUploaded: photosUploaded
        )
        trackTechnicianEvent(event)
    }
    
    static func logScheduleUpdated(availableDays: [Int], availableTimeSlots: Int) {
        let event = ScheduleUpdatedEvent(
            availableDays: availableDays,
            availableTimeSlots: availableTimeSlots
        )
        trackTechnicianEvent(event)
    }
    
    // MARK: - Business Events
    
    static func logServiceAdded(
        id: String,
        name: String,
        category: String,
        price: Double
    ) {
        let event = ServiceAddedEvent(
            serviceId: id,
            serviceName: name,
            serviceCategory: category,
            price: price
        )
        trackBusinessEvent(event)
    }
    
    static func logServiceUpdated(id: String, updatedFields: [String]) {
        let event = ServiceUpdatedEvent(
            serviceId: id,
            updatedFields: updatedFields
        )
        trackBusinessEvent(event)
    }
    
    static func logPriceChanged(
        serviceId: String,
        serviceName: String,
        oldPrice: Double,
        newPrice: Double
    ) {
        let event = PriceChangedEvent(
            serviceId: serviceId,
            serviceName: serviceName,
            oldPrice: oldPrice,
            newPrice: newPrice
        )
        trackBusinessEvent(event)
    }
}