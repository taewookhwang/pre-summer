import Alamofire

enum APIError: Error {
    case networkFailure(Error)
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
}

class APIGateway {
    static let shared = APIGateway()
    private let baseURL = "http://172.30.1.88:3000/api"
    
    private init() {}
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let url = "\(baseURL)\(endpoint)"
        print("Request URL: \(url)") // 디버깅용
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    print("Response success: \(value)") // 성공 로그
                    completion(.success(value))
                case .failure(let error):
                    if let underlyingError = response.error {
                        if underlyingError.isNetworkError {
                            print("Network error: \(underlyingError)")
                            completion(.failure(.networkFailure(underlyingError)))
                        } else if let statusCode = response.response?.statusCode {
                            let message = response.data.flatMap { String(data: $0, encoding: .utf8) }
                            print("Server error [\(statusCode)]: \(message ?? "No message")")
                            completion(.failure(.serverError(statusCode: statusCode, message: message)))
                        } else {
                            print("Decoding error: \(underlyingError)")
                            completion(.failure(.decodingError(underlyingError)))
                        }
                    } else {
                        print("Invalid response")
                        completion(.failure(.invalidResponse))
                    }
                }
            }
    }
}

extension Error {
    var isNetworkError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain
    }
}
