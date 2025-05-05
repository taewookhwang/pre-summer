import Foundation

struct Service: Codable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let duration: Int // „ è
    let category: String
    let imageURL: String?
    let isAvailable: Bool
    let rating: Double?
    let reviewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, duration, category
        case imageURL = "image_url"
        case isAvailable = "is_available"
        case rating, reviewCount = "review_count"
    }
}

struct ServiceCategory: Codable {
    let id: Int
    let name: String
    let description: String
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageURL = "image_url"
    }
}

struct ServiceFilter {
    var category: String?
    var minPrice: Double?
    var maxPrice: Double?
    var minRating: Double?
    var sortBy: SortOption = .recommended
    
    enum SortOption: String {
        case recommended = "recommended"
        case priceAsc = "price_asc"
        case priceDesc = "price_desc"
        case rating = "rating"
        case newest = "newest"
    }
    
    func toParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let category = category {
            params["category"] = category
        }
        
        if let minPrice = minPrice {
            params["min_price"] = minPrice
        }
        
        if let maxPrice = maxPrice {
            params["max_price"] = maxPrice
        }
        
        if let minRating = minRating {
            params["min_rating"] = minRating
        }
        
        params["sort_by"] = sortBy.rawValue
        
        return params
    }
}