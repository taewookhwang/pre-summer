import Foundation

/// 페이지네이션이 적용된 API 응답을 위한 제네릭 래퍼 모델
struct PaginatedResponse<T: Decodable>: Decodable {
    let success: Bool
    let pagination: PaginationMeta?
    let data: T?
    
    // 다양한 응답 형식과 호환되도록 커스텀 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        pagination = try container.decodeIfPresent(PaginationMeta.self, forKey: .pagination)
        
        // 서비스 응답인 경우
        if let services = try? container.decodeIfPresent([Service].self, forKey: .services) {
            data = services as? T
        } 
        // 예약 응답인 경우
        else if let reservations = try? container.decodeIfPresent([Reservation].self, forKey: .reservations) {
            data = reservations as? T
        } 
        // 기타 응답의 경우
        else {
            data = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case success, pagination, services, reservations
    }
}

/// 페이지네이션 메타데이터 모델
struct PaginationMeta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let pages: Int
    var hasNextPage: Bool {
        return page < pages
    }
    var hasPrevPage: Bool {
        return page > 1
    }
    
    enum CodingKeys: String, CodingKey {
        case total, page, limit, pages
    }
}