import Foundation

// APIError는 Network/Error/APIError.swift에 정의되어 있습니다

class APIGateway {
    static let shared = APIGateway()
    
    // 개발 환경 URL 설정
    #if DEBUG
    // private let baseURL = "http://localhost:3000/api" // 로컬 개발 환경
    private let baseURL = "http://172.30.1.88:3000/api" // 개발 테스트용 IP 주소
    #else
    private let baseURL = "https://api.yourproductionserver.com/api" // 프로덕션 서버 (실제 URL로 변경 필요)
    #endif
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // ISO 8601 형식 날짜 처리
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {}
    
    // HTTP 메서드 정의
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // Parameter 타입 정의
    typealias Parameters = [String: Any]
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let url = "\(baseURL)\(endpoint)"
        print("Request URL: \(url)") // 디버깅용
        
        // URL 생성
        guard let requestURL = URL(string: url) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // URLRequest 생성
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        
        // 헤더 추가
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        } else {
            // 기본 헤더 설정
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // 파라미터 추가 (JSON 인코딩)
        if let parameters = parameters {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.networkFailure(error)))
                return
            }
        }
        
        // URLSession 사용
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러 처리
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.networkFailure(error)))
                return
            }
            
            // 응답 처리
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.invalidResponse))
                return
            }
            
            // 상태 코드 확인
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) }
                print("Server error [\(httpResponse.statusCode)]: \(message ?? "No message")")
                completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: message)))
                return
            }
            
            // 데이터 확인
            guard let responseData = data else {
                print("No data received")
                completion(.failure(.invalidResponse))
                return
            }
            
            // 디코딩
            do {
                let decodedData = try self.decoder.decode(T.self, from: responseData)
                print("Response success: \(String(describing: type(of: decodedData)))") // 성공 로그
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}

extension Error {
    var isNetworkError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain
    }
}