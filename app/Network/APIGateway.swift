import Alamofire

enum APIError: Error {
    case networkFailure(Error)
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
}

class APIGateway {
    static let shared = APIGateway()
    private let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let url = "\(baseURL)\(endpoint)"
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if let underlyingError = response.error {
                        if underlyingError.isNetworkError {
                            completion(.failure(.networkFailure(underlyingError)))
                        } else if let statusCode = response.response?.statusCode {
                            let message = response.data.flatMap { String(data: $0, encoding: .utf8) }
                            completion(.failure(.serverError(statusCode: statusCode, message: message)))
                        } else {
                            completion(.failure(.decodingError(underlyingError)))
                        }
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                }
            }
    }
}

// 네트워크 에러 확인용 확장
extension Error {
    var isNetworkError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain
    }
}
