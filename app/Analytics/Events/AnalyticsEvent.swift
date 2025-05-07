import Foundation

protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any] { get }
    var category: String { get }
}

enum EventCategory: String {
    case consumer = "consumer"
    case technician = "technician"
    case business = "business"
    case system = "system"
}
