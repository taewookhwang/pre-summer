import Foundation

protocol KeyValueStorageProtocol {
    func setValue(_ value: Any?, forKey key: String)
    func getString(forKey key: String) -> String?
    func getInt(forKey key: String) -> Int?
    func getDouble(forKey key: String) -> Double?
    func getBool(forKey key: String) -> Bool?
    func getData(forKey key: String) -> Data?
    func getObject<T: Codable>(forKey key: String) -> T?
    func removeValue(forKey key: String)
    func containsKey(_ key: String) -> Bool
    func clear()
}