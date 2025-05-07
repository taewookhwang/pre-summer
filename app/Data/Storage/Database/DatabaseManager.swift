import Foundation

class DatabaseManager: DatabaseProtocol {
    static let shared = DatabaseManager()
    
    private init() {}
    
    // 임시로 UserDefaults를 사용하여 구현함
    private let defaults = UserDefaults.standard
    
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            defaults.set(data, forKey: key)
            return true
        } catch {
            print("DatabaseManager - Failed to save object: \(error.localizedDescription)")
            return false
        }
    }
    
    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            print("DatabaseManager - Failed to load object: \(error.localizedDescription)")
            return nil
        }
    }
    
    func delete(forKey key: String) -> Bool {
        defaults.removeObject(forKey: key)
        return true
    }
    
    func exists(forKey key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    func clearAll() -> Bool {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
            return true
        }
        return false
    }
}