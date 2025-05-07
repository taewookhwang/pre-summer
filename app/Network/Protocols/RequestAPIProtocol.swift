import Foundation

// APIGateway에서 정의된 HTTP 메서드 정의를 동일하게 제공
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol RequestAPIProtocol {
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    func cancelRequest(for endpoint: String)
}

extension RequestAPIProtocol {
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        sendRequest(endpoint: endpoint, method: method, parameters: parameters, completion: completion)
    }
}