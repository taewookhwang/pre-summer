import Foundation

protocol SecureStorageProtocol {
    func saveSecureString(_ value: String, forKey key: String) -> Bool
    func getSecureString(forKey key: String) -> String?
    func deleteSecureItem(forKey key: String) -> Bool
    func containsSecureItem(forKey key: String) -> Bool
    func clearAllSecureItems() -> Bool
}