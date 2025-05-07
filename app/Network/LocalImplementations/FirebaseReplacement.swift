import Foundation

// Firebase 대체 구현 - 이름 충돌 방지를 위해 Mock 접두어 사용
class MockFirebaseApp {
    static func configure() {}
}

class MockAuth {
    static func auth() -> MockAuth {
        return MockAuth()
    }
    
    func signIn(withEmail email: String, password: String, completion: ((MockAuthDataResult?, Error?) -> Void)?) {
        let result = MockAuthDataResult()
        completion?(result, nil)
    }
    
    func createUser(withEmail email: String, password: String, completion: ((MockAuthDataResult?, Error?) -> Void)?) {
        let result = MockAuthDataResult()
        completion?(result, nil)
    }
    
    func signOut() throws {}
    
    func sendPasswordReset(withEmail email: String, completion: ((Error?) -> Void)?) {
        completion?(nil)
    }
    
    var currentUser: MockUser? {
        return MockUser()
    }
}

class MockAuthDataResult {
    var user: MockUser {
        return MockUser()
    }
}

class MockUser {
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

class MockMessaging {
    static func messaging() -> MockMessaging {
        return MockMessaging()
    }
    
    func token(completion: @escaping (String?, Error?) -> Void) {
        completion("mock_token", nil)
    }
    
    func subscribe(toTopic topic: String) {}
    func unsubscribe(fromTopic topic: String) {}
}

class MockFirestore {
    static func firestore() -> MockFirestore {
        return MockFirestore()
    }
    
    func collection(_ path: String) -> MockCollectionReference {
        return MockCollectionReference()
    }
    
    func document(_ path: String) -> MockDocumentReference {
        return MockDocumentReference()
    }
}

class MockCollectionReference {
    func document(_ documentPath: String? = nil) -> MockDocumentReference {
        return MockDocumentReference()
    }
    
    func addDocument(data: [String: Any], completion: ((Error?) -> Void)? = nil) -> MockDocumentReference {
        completion?(nil)
        return MockDocumentReference()
    }
}

class MockDocumentReference {
    // 새로 추가한 컬렉션 메서드
    func collection(_ collectionPath: String) -> MockCollectionReference {
        return MockCollectionReference()
    }
    
    func setData(_ data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func updateData(_ data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func delete(completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
    
    func getDocument(completion: ((MockDocumentSnapshot?, Error?) -> Void)? = nil) {
        let snapshot = MockDocumentSnapshot()
        completion?(snapshot, nil)
    }
}

class MockDocumentSnapshot {
    var exists: Bool {
        return true
    }
    
    // Firebase Firestore uses a data() method, not a data property
    func data() -> [String: Any]? {
        return ["mockField": "mockValue"]
    }
}

// 기존 Firebase 클래스를 Mock 버전으로 별칭 지정
typealias FirebaseApp = MockFirebaseApp
typealias Auth = MockAuth
typealias AuthDataResult = MockAuthDataResult
typealias User = MockUser
typealias Messaging = MockMessaging
typealias Firestore = MockFirestore
typealias CollectionReference = MockCollectionReference
typealias DocumentReference = MockDocumentReference
typealias DocumentSnapshot = MockDocumentSnapshot