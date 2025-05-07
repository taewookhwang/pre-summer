import Foundation

class UserDefaultsManager: KeyValueStorageProtocol {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func setValue(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func getString(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func getInt(forKey key: String) -> Int? {
        return defaults.object(forKey: key) as? Int
    }
    
    func getDouble(forKey key: String) -> Double? {
        return defaults.object(forKey: key) as? Double
    }
    
    func getBool(forKey key: String) -> Bool? {
        return defaults.object(forKey: key) as? Bool
    }
    
    func getData(forKey key: String) -> Data? {
        return defaults.data(forKey: key)
    }
    
    func getObject<T: Codable>(forKey key: String) -> T? {
        guard let data = getData(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("UserDefaultsManager - Failed to decode object: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    func containsKey(_ key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    func clear() {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
    }
    
    // 객체를 쉽게 저장하기 위한 편의 메서드
    func saveObject<T: Codable>(_ object: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            setValue(data, forKey: key)
        } catch {
            print("UserDefaultsManager - Failed to encode object: \(error.localizedDescription)")
        }
    }
}