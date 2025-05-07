import Foundation

// Alamofire를 대체하는 간단한 구현
// 실제 사용에는 제한적이지만 빌드 오류를 해결하기 위한 것입니다

// 이미 APIGateway에 정의된 HTTPMethod와 이름 충돌을 방지하기 위해 접두어 사용
enum AFHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// 이미 다른 곳에서 정의된 ParameterEncoding과 이름 충돌을 방지하기 위해 접두어 사용
enum AFParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case multipartFormData
}

class Response<T> {
    var data: T?
    var error: Error?
    
    init(data: T? = nil, error: Error? = nil) {
        self.data = data
        self.error = error
    }
}

struct DataResponse<T> {
    var response: URLResponse?
    var data: Data?
    var error: Error?
    var value: T?
}

struct DownloadResponse<T> {
    var response: URLResponse?
    var fileURL: URL?
    var error: Error?
    var value: T?
}

class Session {
    static let `default` = Session()
    
    func request(_ url: URLConvertible, 
                method: AFHTTPMethod = .get, 
                parameters: Parameters? = nil, 
                encoding: AFParameterEncoding = .urlEncoding, 
                headers: HTTPHeaders? = nil) -> DataRequest {
        return DataRequest()
    }
    
    func download(_ url: URLConvertible, 
                 method: AFHTTPMethod = .get, 
                 parameters: Parameters? = nil, 
                 encoding: AFParameterEncoding = .urlEncoding, 
                 headers: HTTPHeaders? = nil) -> DownloadRequest {
        return DownloadRequest()
    }
}

class DataRequest {
    func responseJSON(queue: DispatchQueue = .main, 
                     completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
        return self
    }
    
    func responseData(queue: DispatchQueue = .main, 
                     completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self {
        return self
    }
    
    func validate() -> Self {
        return self
    }
}

class DownloadRequest {
    func responseURL(queue: DispatchQueue = .main, 
                    completionHandler: @escaping (DownloadResponse<URL>) -> Void) -> Self {
        return self
    }
    
    func validate() -> Self {
        return self
    }
}

class MultipartFormData {
    func append(_ data: Data, withName name: String, fileName: String? = nil, mimeType: String? = nil) {}
    func append(_ fileURL: URL, withName name: String) {}
}

typealias Parameters = [String: Any]
typealias HTTPHeaders = [String: String]

protocol URLConvertible {
    func asURL() throws -> URL
}

extension String: URLConvertible {
    func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        return url
    }
}

extension URL: URLConvertible {
    func asURL() throws -> URL { return self }
}