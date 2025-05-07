import Foundation

// Firebase Storage 대체 구현
class MockStorage {
    static func storage() -> MockStorage {
        return MockStorage()
    }
    
    func reference() -> MockStorageReference {
        return MockStorageReference()
    }
}

class MockStorageReference {
    func child(_ path: String) -> MockStorageReference {
        return MockStorageReference()
    }
    
    func putData(_ data: Data, metadata: [String: Any]? = nil, completion: @escaping (MockStorageMetadata?, Error?) -> Void) {
        let metadata = MockStorageMetadata()
        completion(metadata, nil)
    }
    
    func getData(maxSize: Int64, completion: @escaping (Data?, Error?) -> Void) {
        // 실제 앱에서는 파일 스토리지에서 데이터 로드
        // 여기서는 임시 데이터 생성
        let dummyData = "Test data".data(using: .utf8)
        completion(dummyData, nil)
    }
    
    func delete(completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    var downloadURL: URL? {
        return URL(string: "https://example.com/mock-download-url")
    }
}

class MockStorageMetadata {
    var downloadURL: URL? {
        return URL(string: "https://example.com/mock-download-url")
    }
    
    var path: String {
        return "mock/path/file.jpg"
    }
}

// 기존 Firebase Storage 클래스를 Mock 버전으로 별칭 지정
typealias Storage = MockStorage
typealias StorageReference = MockStorageReference
typealias StorageMetadata = MockStorageMetadata