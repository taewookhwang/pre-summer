import Foundation

// APIError는 Network/Error/APIError.swift에 정의되어 있습니다

class APIGateway {
    static let shared = APIGateway()
    
    // 개발 환경 URL 설정
    #if DEBUG
    private let baseURL = "http://localhost:3000/api" // 로컬 개발 환경
    // private let baseURL = "http://172.30.1.88:3000/api" // 개발 테스트용 IP 주소
    #else
    private let baseURL = "https://api.yourproductionserver.com/api" // 프로덕션 서버 (실제 URL로 변경 필요)
    #endif
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        // 더 유연한 날짜 디코딩 전략 (ISO 8601 및 다른 형식 지원)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Full ISO8601 with milliseconds
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try full ISO8601 first
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try ISO8601WithFractionalSeconds
            if #available(iOS 10.0, *) {
                if let date = ISO8601DateFormatter().date(from: dateString) {
                    return date
                }
            }
            
            // Try simple date format
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try simple date with time
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Other formats
            dateFormatter.dateFormat = "yyyy/MM/dd"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // If all else fails, throw an error
            throw DecodingError.dataCorruptedError(
                in: container, 
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
        
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
        retrying: Bool = false, // 토큰 갱신 후 재시도 플래그
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
        
        // 파라미터 추가 (GET 요청은 쿼리 파라미터, 다른 메서드는 JSON 바디)
        if let parameters = parameters {
            if method == .get {
                // GET 요청의 경우 URL 쿼리 파라미터로 추가
                var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)!
                var queryItems = [URLQueryItem]()
                
                for (key, value) in parameters {
                    // 각 파라미터 값을 문자열로 변환
                    let stringValue = "\(value)"
                    let queryItem = URLQueryItem(name: key, value: stringValue)
                    queryItems.append(queryItem)
                }
                
                components.queryItems = queryItems
                
                // URL 업데이트
                if let url = components.url {
                    request.url = url
                    print("GET URL with query parameters: \(url.absoluteString)")
                }
            } else {
                // POST, PUT, DELETE 등은 JSON 바디로 추가
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                    request.httpBody = jsonData
                } catch {
                    completion(.failure(.networkFailure(error)))
                    return
                }
            }
        }
        
        // URLSession 사용 (큰 응답 데이터 처리를 위한 설정)
        let configuration = URLSessionConfiguration.default
        // 최대 응답 크기 및 메모리 용량 증가
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.timeoutIntervalForRequest = 60.0 // 타임아웃 증가
        configuration.timeoutIntervalForResource = 120.0 // 리소스 타임아웃 증가
        
        // 응답 데이터 크기 제한 설정 향상 (24MB, 약 25,165,824 바이트)
        // NSURLSession은 기본적으로 데이터 크기에 제한이 있음
        configuration.httpShouldUsePipelining = true
        configuration.httpMaximumConnectionsPerHost = 15 // 연결 수 증가
        
        // 데이터 압축 활성화 (iOS 11 이상)
        if #available(iOS 11.0, *) {
            configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip, deflate, br"]
        } else {
            configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip, deflate"]
        }
        
        // 캐시 디렉토리 설정 및 확인
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let apiCacheDirectory = cachesDirectory.appendingPathComponent("APICache")
        
        // 디렉토리가 없는 경우 생성
        do {
            if !FileManager.default.fileExists(atPath: apiCacheDirectory.path) {
                try FileManager.default.createDirectory(
                    at: apiCacheDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        } catch {
            print("Failed to create API cache directory: \(error)")
        }
        
        // 메모리 사용량 증가
        configuration.urlCache = URLCache(
            memoryCapacity: 30 * 1024 * 1024, // 30MB
            diskCapacity: 150 * 1024 * 1024,  // 150MB
            diskPath: apiCacheDirectory.path
        )
        
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { data, response, error in
            // 에러 처리
            if let error = error {
                print("Network error: \(error)")
                
                // 리소스 크기 초과 에러에 대한 향상된 처리
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == -1103 {
                    print("⚠️ Resource exceeds maximum size error detected - consider chunking data or increasing limits")
                    print("⚠️ URL: \(request.url?.absoluteString ?? "unknown")")
                    print("⚠️ Make sure pagination is properly implemented for this endpoint")
                    
                    // 페이지네이션 파라미터 검사 및 자동 수정 시도
                    if let url = request.url {
                        let urlString = url.absoluteString
                        let hasPagination = urlString.contains("page=") && urlString.contains("limit=")
                        
                        if hasPagination {
                            print("✅ Pagination parameters are present in URL, but response may still be too large")
                            print("🔄 Consider reducing 'limit' parameter or applying more filters")
                            
                            // 현재 URL에서 limit 값을 추출하여 감소시키는 논리를 구현할 수 있음
                            // 여기서는 알림만 제공
                            
                            completion(.failure(.resourceExceedsMaximumSize(url: urlString)))
                        } else {
                            print("❌ Pagination parameters (page and limit) appear to be missing from URL")
                            print("💡 TIP: Add '?page=1&limit=10' to URL to implement pagination")
                            
                            // 개발자가 파라미터를 추가하도록 구체적인 에러 메시지 제공
                            let errorMessage = "Response data is too large. Add pagination parameters (page and limit) to reduce response size."
                            completion(.failure(.paginationRequired(url: urlString, message: errorMessage)))
                        }
                    } else {
                        completion(.failure(.resourceExceedsMaximumSize(url: request.url?.absoluteString)))
                    }
                } else {
                    completion(.failure(.networkFailure(error)))
                }
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
                
                // 401 에러 처리 (인증 에러)
                if httpResponse.statusCode == 401 && !retrying {
                    print("⚠️ 401 Unauthorized - attempting to refresh token")
                    
                    // 토큰 갱신 시도 - 새로운 String 반환 메서드 사용
                    AuthService.shared.refreshTokenWithStringResult { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let newToken):
                            print("✅ Token refreshed successfully, retrying original request")
                            
                            // 새 토큰으로 원래 요청 재시도
                            var updatedHeaders = headers ?? [:]
                            updatedHeaders["Authorization"] = "Bearer \(newToken)"
                            
                            self.request(
                                endpoint,
                                method: method,
                                parameters: parameters,
                                headers: updatedHeaders,
                                retrying: true, // 재시도 중임을 표시
                                completion: completion
                            )
                            
                        case .failure(let error):
                            print("❌ Token refresh failed: \(error.localizedDescription)")
                            
                            // 테스트 토큰 형식 오류 확인 (백엔드 authMiddleware 기대 형식과 불일치)
                            if let refreshToken = AuthService.shared.getRefreshToken(),
                               refreshToken.hasPrefix("test_") {
                                let parts = refreshToken.split(separator: "_")
                                
                                // 토큰 형식 검사하여 사용자에게 적절한 메시지 제공
                                if parts.count < 4 || Int(parts.last?.description ?? "") == nil {
                                    print("⚠️ 테스트 토큰 형식 오류: 백엔드가 'test_refresh_role_id' 형식을 기대하지만 현재 토큰은 다른 형식입니다.")
                                    print("⚠️ 현재 토큰: \(refreshToken)")
                                    print("⚠️ 재로그인하여 새 형식의 토큰을 발급받으세요.")
                                }
                            }
                            
                            // 세션 만료 알림 보내기
                            NotificationCenter.default.post(name: .userSessionExpired, object: nil)
                            NotificationCenter.default.post(name: .tokenExpired, object: nil) // 기존 구현 호환성 유지
                            
                            // 로그인 화면으로 리다이렉트를 위한 에러 반환
                            completion(.failure(.unauthorized))
                        }
                    }
                } else if httpResponse.statusCode == 401 && retrying {
                    // 토큰 갱신 후에도 401 오류가 발생하면 세션 만료로 처리
                    print("❌ Still getting 401 after token refresh - session must be invalid")
                    NotificationCenter.default.post(name: .userSessionExpired, object: nil)
                    NotificationCenter.default.post(name: .tokenExpired, object: nil) // 기존 구현 호환성 유지
                    completion(.failure(.unauthorized))
                } else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: message)))
                }
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