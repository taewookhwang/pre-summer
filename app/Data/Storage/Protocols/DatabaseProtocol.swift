import Foundation

protocol DatabaseProtocol {
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool
    func load<T: Codable>(forKey key: String) -> T?
    func delete(forKey key: String) -> Bool
    func exists(forKey key: String) -> Bool
    func clearAll() -> Bool
}