import Foundation

struct Service: Codable {
    let id: String
    let name: String
    let description: String
    let price: String
    let duration: Int // in minutes
    let category: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let imageURL: String?
    let rating: Double?
    let reviewCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, category
        case price
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case imageURL = "image_url"
        case rating, reviewCount = "review_count"
    }
    
    // Computed property to convert String price to Double
    var priceValue: Double {
        return Double(price) ?? 0.0
    }
    
    // Standard initializer for creating instances
    init(id: String, name: String, description: String, price: String, duration: Int,
         category: String, isActive: Bool, createdAt: Date, updatedAt: Date,
         imageURL: String? = nil, rating: Double? = nil, reviewCount: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.category = category
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageURL = imageURL
        self.rating = rating
        self.reviewCount = reviewCount
    }
}

struct ServiceCategory: Codable {
    let id: String
    let name: String
    let description: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageURL = "image_url"
    }
    
    // Standard initializer for creating instances
    init(id: String, name: String, description: String? = nil, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
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