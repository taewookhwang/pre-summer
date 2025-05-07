import Foundation

// 실제 Realm을 사용하지 않고, 임시 메모리 저장소입니다.
// 실제 구현시 RealmSwift를 import하여 진짜 Realm 객체들을 사용해야 합니다.
class RealmManager {
    static let shared = RealmManager()
    
    private init() {}
    
    // 메모리 내에만 존재하는 임시 저장소
    private var storage: [String: Any] = [:]
    
    // 객체 저장
    func saveObject<T: Codable>(_ object: T, withId id: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            storage[id] = data
            return true
        } catch {
            print("RealmManager - Failed to save object: \(error.localizedDescription)")
            return false
        }
    }
    
    // 객체 불러오기
    func getObject<T: Codable>(withId id: String) -> T? {
        guard let data = storage[id] as? Data else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("RealmManager - Failed to get object: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 객체 삭제
    func deleteObject(withId id: String) -> Bool {
        storage.removeValue(forKey: id)
        return true
    }
    
    // 전체 삭제
    func deleteAllObjects() {
        storage.removeAll()
    }
}