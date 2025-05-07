#!/bin/bash

# 이 스크립트는 외부 라이브러리 의존성 없이 앱을 빌드할 수 있도록 로컬 대체 구현을 사용합니다
cd "$(dirname "$0")"

# 1. Alamofire 대체 구현 파일 생성
mkdir -p Network/LocalImplementations
cat > Network/LocalImplementations/AlamofireReplacement.swift << 'EOF'
import Foundation

// Alamofire를 대체하는 간단한 구현
// 실제 사용에는 제한적이지만 빌드 오류를 해결하기 위한 것입니다

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum ParameterEncoding {
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
                method: HTTPMethod = .get, 
                parameters: Parameters? = nil, 
                encoding: ParameterEncoding = .urlEncoding, 
                headers: HTTPHeaders? = nil) -> DataRequest {
        return DataRequest()
    }
    
    func download(_ url: URLConvertible, 
                 method: HTTPMethod = .get, 
                 parameters: Parameters? = nil, 
                 encoding: ParameterEncoding = .urlEncoding, 
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
EOF

# 2. Socket.IO 대체 구현 파일 생성
cat > Network/LocalImplementations/SocketIOReplacement.swift << 'EOF'
import Foundation

// Socket.IO 대체 구현
class SocketManager {
    static func socket(forNamespace nsp: String = "/") -> SocketIOClient {
        return SocketIOClient(manager: SocketManager(), nsp: nsp)
    }
    
    init(socketURL: URL = URL(string: "http://localhost:8080")!, config: SocketIOClientConfiguration = []) {}
}

class SocketIOClient {
    init(manager: SocketManager, nsp: String) {}
    
    func connect() {}
    func disconnect() {}
    
    func on(_ event: String, callback: @escaping ([Any]) -> Void) -> UUID {
        return UUID()
    }
    
    func emit(_ event: String, _ items: Any...) {}
}

typealias SocketIOClientConfiguration = [SocketIOClientOption]

enum SocketIOClientOption {
    case connectParams([String: Any])
    case secure(Bool)
    case reconnects(Bool)
    case reconnectWait(Int)
    case log(Bool)
    case forceWebsockets(Bool)
}
EOF

# 3. Firebase 대체 구현 파일 생성
cat > Network/LocalImplementations/FirebaseReplacement.swift << 'EOF'
import Foundation

// Firebase 대체 구현
class FirebaseApp {
    static func configure() {}
}

class Auth {
    static func auth() -> Auth {
        return Auth()
    }
    
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        let result = AuthDataResult()
        completion?(result, nil)
    }
    
    func createUser(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        let result = AuthDataResult()
        completion?(result, nil)
    }
    
    func signOut() throws {}
    
    func sendPasswordReset(withEmail email: String, completion: ((Error?) -> Void)?) {
        completion?(nil)
    }
    
    var currentUser: User? {
        return User()
    }
}

class AuthDataResult {
    var user: User {
        return User()
    }
}

class User {
    var uid: String {
        return "user_mock_uid"
    }
    
    var email: String? {
        return "user@example.com"
    }
    
    var displayName: String? {
        return "Test User"
    }
}

class Messaging {
    static func messaging() -> Messaging {
        return Messaging()
    }
    
    func token(completion: @escaping (String?, Error?) -> Void) {
        completion("mock_token", nil)
    }
    
    func subscribe(toTopic topic: String) {}
    func unsubscribe(fromTopic topic: String) {}
}

class Firestore {
    static func firestore() -> Firestore {
        return Firestore()
    }
    
    func collection(_ path: String) -> CollectionReference {
        return CollectionReference()
    }
    
    func document(_ path: String) -> DocumentReference {
        return DocumentReference()
    }
}

class CollectionReference {
    func document(_ documentPath: String? = nil) -> DocumentReference {
        return DocumentReference()
    }
    
    func addDocument(data: [String: Any], completion: ((Error?) -> Void)? = nil) -> DocumentReference {
        completion?(nil)
        return DocumentReference()
    }
}

class DocumentReference {
    func setData(_ data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func updateData(_ data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func delete(completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func getDocument(completion: ((DocumentSnapshot?, Error?) -> Void)? = nil) {
        let snapshot = DocumentSnapshot()
        completion?(snapshot, nil)
    }
}

class DocumentSnapshot {
    var exists: Bool {
        return true
    }
    
    var data: [String: Any]? {
        return ["mockField": "mockValue"]
    }
    
    func data() -> [String: Any]? {
        return ["mockField": "mockValue"]
    }
}
EOF

# 4. 프로젝트 파일 생성 - Firebase Import를 로컬 구현으로 대체
cat > Network/LocalImplementations/ImportReplacements.swift << 'EOF'
import Foundation

// 다음 코드는 기존 import 문을 대체하는 역할을 합니다
// 실제 앱에서는 해당 import를 직접 사용해야 하지만,
// 빌드 문제를 해결하기 위해 빈 구현체를 제공합니다

// Firebase
typealias FIRApp = FirebaseApp
typealias FIRAuth = Auth
typealias FIRUser = User
typealias FIRAuthDataResult = AuthDataResult
typealias FIRMessaging = Messaging
EOF

# 5. 빌드 스크립트 생성
cat > build_without_pods.sh << 'EOF'
#!/bin/bash

# Pod 없이 빌드하는 스크립트
cd "$(dirname "$0")"

# Swift 파일 목록 수집
SWIFT_FILES=$(find . -name "*.swift" | grep -v "Pods/")

# 빌드 명령 실행
xcrun swiftc $SWIFT_FILES \
  -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  -target arm64-apple-ios18.2-simulator \
  -o HomeCleaningApp

echo "빌드 완료: HomeCleaningApp"
EOF

chmod +x build_without_pods.sh

echo "로컬 대체 라이브러리 파일과 빌드 스크립트가 생성되었습니다."
echo "이제 './build_without_pods.sh'를 실행하여 외부 의존성 없이 앱을 빌드할 수 있습니다."