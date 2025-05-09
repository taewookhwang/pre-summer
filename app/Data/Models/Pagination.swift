import Foundation

/// 페이지네이션이 적용된 API 응답을 위한 제네릭 래퍼 모델
struct PaginatedResponse<T: Decodable>: Decodable {
    let success: Bool
    let pagination: PaginationMeta?
    let data: T?

    // 추가 접근자를 위한 저장 속성
    let services: [Service]?
    let reservations: [Reservation]?
    let jobs: [Job]?

    // 다양한 응답 형식과 호환되도록 커스텀 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        pagination = try container.decodeIfPresent(PaginationMeta.self, forKey: .pagination)

        // 각각의 응답 유형 지원 - 에러 처리 강화
        do {
            services = try container.decodeIfPresent([Service].self, forKey: .services)
        } catch {
            print("Error decoding services: \(error)")
            services = nil
        }

        do {
            reservations = try container.decodeIfPresent([Reservation].self, forKey: .reservations)
        } catch {
            print("Error decoding reservations: \(error)")
            reservations = nil
        }

        do {
            jobs = try container.decodeIfPresent([Job].self, forKey: .jobs)
        } catch {
            print("Error decoding jobs: \(error)")
            jobs = nil
        }

        // 직접 data 필드 디코딩 시도
        if let dataContainer = try? container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .data) {
            // 데이터가 data 필드 안에 있는 경우
            data = try? T(from: decoder)
        } else {
            // 제네릭 데이터 타입 설정
            if let services = services, T.self == [Service].self {
                data = services as? T
            } else if let reservations = reservations, T.self == [Reservation].self {
                data = reservations as? T
            } else if let jobs = jobs, T.self == [Job].self {
                data = jobs as? T
            } else {
                // 직접 디코딩 시도
                do {
                    data = try container.decodeIfPresent(T.self, forKey: .data)
                } catch {
                    print("Error decoding data field as \(T.self): \(error)")
                    data = nil
                }
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case success, pagination, services, reservations, jobs, data
    }

    // 제네릭 키를 위한 열거형
    private struct GenericCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
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
    
    // Standard initializer
    init(page: Int, limit: Int, total: Int, pages: Int) {
        self.page = page
        self.limit = limit
        self.total = total
        self.pages = pages
    }
    
    enum CodingKeys: String, CodingKey {
        case total, page, limit, pages
    }
    
    // Alternative keys for different API responses
    private enum AlternativeCodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case itemsPerPage = "items_per_page"
        case totalItems = "total_items"
        case totalPages = "total_pages"
    }
    
    // 페이지네이션 메타데이터 형식이 일치하지 않을 경우의 호환성 처리
    init(from decoder: Decoder) throws {
        // Try to decode with standard keys first
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let page = try? container.decode(Int.self, forKey: .page),
           let limit = try? container.decode(Int.self, forKey: .limit),
           let total = try? container.decode(Int.self, forKey: .total),
           let pages = try? container.decode(Int.self, forKey: .pages) {
            
            self.init(page: page, limit: limit, total: total, pages: pages)
            return
        }
        
        // Fallback to alternative keys
        let alternativeContainer = try decoder.container(keyedBy: AlternativeCodingKeys.self)
        let currentPage = try alternativeContainer.decodeIfPresent(Int.self, forKey: .currentPage) ?? 1
        let itemsPerPage = try alternativeContainer.decodeIfPresent(Int.self, forKey: .itemsPerPage) ?? 10
        let totalItems = try alternativeContainer.decodeIfPresent(Int.self, forKey: .totalItems) ?? 0
        let totalPages = try alternativeContainer.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
        
        self.init(page: currentPage, limit: itemsPerPage, total: totalItems, pages: totalPages)
    }
}