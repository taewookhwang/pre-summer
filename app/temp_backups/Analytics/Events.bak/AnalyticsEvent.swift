import Foundation

protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any] { get }
    var category: String { get }
}

extension AnalyticsEvent {
    func toDict() -> [String: Any] {
        var result = parameters
        result["event_category"] = category
        return result
    }
}

enum EventCategory: String {
    case consumer = "consumer"
    case technician = "technician"
    case business = "business"
    case system = "system"
}