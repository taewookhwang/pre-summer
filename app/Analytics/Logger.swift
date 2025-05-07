import Foundation

enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}

class Logger {
    #if DEBUG
    static var minimumLogLevel: LogLevel = .debug
    #else
    static var minimumLogLevel: LogLevel = .warning
    #endif
    
    static func log(_ message: String, level: LogLevel, file: String = #file, line: Int = #line, function: String = #function) {
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        
        print("[\(timestamp)] [\(level.description)] [\(fileName):\(line)] \(function) - \(message)")
    }
    
    static func debug(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .debug, file: file, line: line, function: function)
    }
    
    static func info(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .info, file: file, line: line, function: function)
    }
    
    static func warning(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .warning, file: file, line: line, function: function)
    }
    
    static func error(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .error, file: file, line: line, function: function)
    }
}