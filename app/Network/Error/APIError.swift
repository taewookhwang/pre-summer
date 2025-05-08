import Foundation

enum APIError: Error {
    case networkFailure(Error)
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case customError(message: String)
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case serverUnavailable
    case resourceExceedsMaximumSize(url: String?)
    case paginationRequired(url: String?, message: String)
    
    var localizedDescription: String {
        switch self {
        case .networkFailure(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .invalidResponse:
            return "유효하지 않은 응답"
        case .serverError(let statusCode, let message):
            return "서버 오류 (\(statusCode)): \(message ?? "알 수 없는 오류")"
        case .decodingError(let error):
            return "데이터 변환 오류: \(error.localizedDescription)"
        case .customError(let message):
            return message
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .timeout:
            return "요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요."
        case .serverUnavailable:
            return "서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."
        case .resourceExceedsMaximumSize(let url):
            return "응답 데이터가 너무 큽니다. \(url != nil ? "URL: \(url!)" : "")"
        case .paginationRequired(let url, let message):
            return "\(message) \(url != nil ? "URL: \(url!)" : "")"
        }
    }
    
    // Helper method for creating APIError from HTTP status code
    static func from(statusCode: Int, message: String? = nil) -> APIError {
        switch statusCode {
        case 400:
            return .customError(message: message ?? "잘못된 요청입니다.")
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 408:
            return .timeout
        case 500...599:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .serverError(statusCode: statusCode, message: message)
        }
    }
}

// Extension for handling common error scenarios
extension APIError {
    // Check if error is related to authentication
    var isAuthError: Bool {
        switch self {
        case .unauthorized:
            return true
        case .serverError(let statusCode, _):
            return statusCode == 401
        default:
            return false
        }
    }
    
    // Check if error is related to network connectivity
    var isConnectivityError: Bool {
        switch self {
        case .networkFailure(let error):
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain &&
                (nsError.code == NSURLErrorNotConnectedToInternet ||
                 nsError.code == NSURLErrorNetworkConnectionLost)
        case .timeout, .serverUnavailable:
            return true
        case .resourceExceedsMaximumSize, .paginationRequired:
            return false // These are response size or implementation issues, not connectivity
        default:
            return false
        }
    }
    
    // User-friendly message for UI display
    var userFriendlyMessage: String {
        if isConnectivityError {
            return "인터넷 연결을 확인해주세요."
        } else if isAuthError {
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        } else if case .resourceExceedsMaximumSize = self {
            return "데이터를 분할하여 로딩 중입니다. 잠시만 기다려주세요."
        } else if case .paginationRequired(_, let message) = self {
            return "페이지네이션이 필요합니다: \(message)"
        } else {
            return localizedDescription
        }
    }
}