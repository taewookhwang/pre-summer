import Foundation

class ReportingService {
    static let shared = ReportingService()
    
    private init() {}
    
    // API 의존성
    private let reportingAPI = ReportingAPI.shared
    
    // MARK: - 보고서 관련 기능
    
    // 고객 데이터 보고서 가져오기
    func getCustomerReport(parameters: ReportParameters, completion: @escaping (Result<CustomerReport, Error>) -> Void) {
        reportingAPI.getCustomerReport(parameters: parameters.toDictionary()) { result in
            switch result {
            case .success(let response):
                completion(.success(response.report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 기술자 데이터 보고서 가져오기
    func getTechnicianReport(parameters: ReportParameters, completion: @escaping (Result<TechnicianReport, Error>) -> Void) {
        reportingAPI.getTechnicianReport(parameters: parameters.toDictionary()) { result in
            switch result {
            case .success(let response):
                completion(.success(response.report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 매출 보고서 가져오기
    func getRevenueReport(parameters: ReportParameters, completion: @escaping (Result<RevenueReport, Error>) -> Void) {
        reportingAPI.getRevenueReport(parameters: parameters.toDictionary()) { result in
            switch result {
            case .success(let response):
                completion(.success(response.report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 서비스 이용 보고서 가져오기
    func getServiceUsageReport(parameters: ReportParameters, completion: @escaping (Result<ServiceUsageReport, Error>) -> Void) {
        reportingAPI.getServiceUsageReport(parameters: parameters.toDictionary()) { result in
            switch result {
            case .success(let response):
                completion(.success(response.report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 리뷰 및 평가 보고서 가져오기
    func getReviewsReport(parameters: ReportParameters, completion: @escaping (Result<ReviewsReport, Error>) -> Void) {
        reportingAPI.getReviewsReport(parameters: parameters.toDictionary()) { result in
            switch result {
            case .success(let response):
                completion(.success(response.report))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 대시보드 기능
    
    // 관리자 대시보드 데이터 가져오기
    func getAdminDashboardData(completion: @escaping (Result<ReportingDashboardData, Error>) -> Void) {
        reportingAPI.getAdminDashboard { result in
            switch result {
            case .success(let response):
                completion(.success(response.dashboard))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 관리자 대시보드 데이터 날짜 업데이트
    func updateDashboardDateRange(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<ReportingDashboardData, Error>) -> Void
    ) {
        let parameters: [String: Any] = [
            "start_date": formatDate(startDate),
            "end_date": formatDate(endDate)
        ]
        
        reportingAPI.updateDashboardDateRange(parameters: parameters) { result in
            switch result {
            case .success(let response):
                completion(.success(response.dashboard))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 내보내기 기능
    
    // 데이터를 CSV 형식으로 내보내기
    func exportDataToCSV(
        reportType: ReportType,
        parameters: ReportParameters,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let parameters = parameters.toDictionary().merging(["format": "csv"], uniquingKeysWith: { $1 })
        
        reportingAPI.exportReport(type: reportType.rawValue, parameters: parameters) { result in
            switch result {
            case .success(let response):
                // 다운로드 URL
                guard let url = URL(string: response.downloadURL) else {
                    completion(.failure(ReportingError.invalidURL))
                    return
                }
                
                // CSV 파일 다운로드
                self.downloadFile(from: url) { result in
                    switch result {
                    case .success(let fileURL):
                        completion(.success(fileURL))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 데이터를 Excel 형식으로 내보내기
    func exportDataToExcel(
        reportType: ReportType,
        parameters: ReportParameters,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let parameters = parameters.toDictionary().merging(["format": "excel"], uniquingKeysWith: { $1 })
        
        reportingAPI.exportReport(type: reportType.rawValue, parameters: parameters) { result in
            switch result {
            case .success(let response):
                // 다운로드 URL
                guard let url = URL(string: response.downloadURL) else {
                    completion(.failure(ReportingError.invalidURL))
                    return
                }
                
                // Excel 파일 다운로드
                self.downloadFile(from: url) { result in
                    switch result {
                    case .success(let fileURL):
                        completion(.success(fileURL))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 유틸리티 기능
    
    // 파일 다운로드 유틸리티 기능
    private func downloadFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let tempURL = tempURL else {
                completion(.failure(ReportingError.downloadFailed))
                return
            }
            
            // 파일 이름 추출
            let fileName = response?.suggestedFilename ?? url.lastPathComponent
            
            // 문서 디렉토리에 파일 저장
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            
            // 기존 파일 제거
            try? FileManager.default.removeItem(at: destinationURL)
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        downloadTask.resume()
    }
    
    // 날짜 형식 유틸리티 기능
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 모델

enum ReportType: String {
    case customer = "customer"
    case technician = "technician"
    case revenue = "revenue"
    case serviceUsage = "service_usage"
    case reviews = "reviews"
}

enum ReportTimeFrame: String {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
}

struct ReportParameters {
    var startDate: Date
    var endDate: Date
    var timeFrame: ReportTimeFrame
    var includeDetails: Bool
    var filterBy: [String: Any]?
    
    func toDictionary() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var parameters: [String: Any] = [
            "start_date": dateFormatter.string(from: startDate),
            "end_date": dateFormatter.string(from: endDate),
            "time_frame": timeFrame.rawValue,
            "include_details": includeDetails
        ]
        
        if let filterBy = filterBy {
            parameters["filter_by"] = filterBy
        }
        
        return parameters
    }
}

struct ChartDataPoint: Codable {
    let label: String
    let value: Double
}

struct ReportDateRange: Codable {
    let startDate: Date
    let endDate: Date
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

// 고객 보고서
struct CustomerReport: Codable {
    let dateRange: ReportDateRange
    let totalCustomers: Int
    let newCustomers: Int
    let activeCustomers: Int
    let customerRetentionRate: Double
    let customerGrowthRate: Double
    let customersByRegion: [ChartDataPoint]
    let customerActivity: [ChartDataPoint]
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case totalCustomers = "total_customers"
        case newCustomers = "new_customers"
        case activeCustomers = "active_customers"
        case customerRetentionRate = "customer_retention_rate"
        case customerGrowthRate = "customer_growth_rate"
        case customersByRegion = "customers_by_region"
        case customerActivity = "customer_activity"
    }
}

// 기술자 보고서
struct TechnicianReport: Codable {
    let dateRange: ReportDateRange
    let totalTechnicians: Int
    let activeTechnicians: Int
    let averageRating: Double
    let averageJobsPerTechnician: Double
    let topPerformers: [TechnicianPerformance]
    let techniciansByRegion: [ChartDataPoint]
    let technicianActivity: [ChartDataPoint]
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case totalTechnicians = "total_technicians"
        case activeTechnicians = "active_technicians"
        case averageRating = "average_rating"
        case averageJobsPerTechnician = "average_jobs_per_technician"
        case topPerformers = "top_performers"
        case techniciansByRegion = "technicians_by_region"
        case technicianActivity = "technician_activity"
    }
}

struct TechnicianPerformance: Codable {
    let technicianId: Int
    let name: String
    let completedJobs: Int
    let rating: Double
    let earnings: Double
    
    enum CodingKeys: String, CodingKey {
        case technicianId = "technician_id"
        case name
        case completedJobs = "completed_jobs"
        case rating
        case earnings
    }
}

// 매출 보고서
struct RevenueReport: Codable {
    let dateRange: ReportDateRange
    let totalRevenue: Double
    let revenueByTimeFrame: [ChartDataPoint]
    let revenueByService: [ChartDataPoint]
    let revenueByRegion: [ChartDataPoint]
    let averageOrderValue: Double
    let paymentMethodDistribution: [ChartDataPoint]
    let revenueGrowthRate: Double
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case totalRevenue = "total_revenue"
        case revenueByTimeFrame = "revenue_by_time_frame"
        case revenueByService = "revenue_by_service"
        case revenueByRegion = "revenue_by_region"
        case averageOrderValue = "average_order_value"
        case paymentMethodDistribution = "payment_method_distribution"
        case revenueGrowthRate = "revenue_growth_rate"
    }
}

// 서비스 이용 보고서
struct ServiceUsageReport: Codable {
    let dateRange: ReportDateRange
    let totalServices: Int
    let totalCompletedServices: Int
    let topServices: [ServiceUsage]
    let servicesByTimeFrame: [ChartDataPoint]
    let averageServiceDuration: Double
    let serviceDistributionByDay: [ChartDataPoint]
    let cancellationRate: Double
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case totalServices = "total_services"
        case totalCompletedServices = "total_completed_services"
        case topServices = "top_services"
        case servicesByTimeFrame = "services_by_time_frame"
        case averageServiceDuration = "average_service_duration"
        case serviceDistributionByDay = "service_distribution_by_day"
        case cancellationRate = "cancellation_rate"
    }
}

struct ServiceUsage: Codable {
    let serviceId: String
    let name: String
    let count: Int
    let revenue: Double
    
    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case name
        case count
        case revenue
    }
}

// 리뷰 및 평가 보고서
struct ReviewsReport: Codable {
    let dateRange: ReportDateRange
    let totalReviews: Int
    let averageRating: Double
    let ratingDistribution: [ChartDataPoint]
    let reviewsByTimeFrame: [ChartDataPoint]
    let topReviewedServices: [ServiceReviews]
    let topReviewedTechnicians: [TechnicianReviews]
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case totalReviews = "total_reviews"
        case averageRating = "average_rating"
        case ratingDistribution = "rating_distribution"
        case reviewsByTimeFrame = "reviews_by_time_frame"
        case topReviewedServices = "top_reviewed_services"
        case topReviewedTechnicians = "top_reviewed_technicians"
    }
}

struct ServiceReviews: Codable {
    let serviceId: String
    let name: String
    let reviewCount: Int
    let averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case name
        case reviewCount = "review_count"
        case averageRating = "average_rating"
    }
}

struct TechnicianReviews: Codable {
    let technicianId: Int
    let name: String
    let reviewCount: Int
    let averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case technicianId = "technician_id"
        case name
        case reviewCount = "review_count"
        case averageRating = "average_rating"
    }
}

// 관리자 대시보드 데이터
struct ReportingDashboardData: Codable {
    let dateRange: ReportDateRange
    let statistics: DashboardStatistics
    let revenueChart: [ChartDataPoint]
    let userGrowthChart: [ChartDataPoint]
    let serviceDistribution: [ChartDataPoint]
    let recentReservations: [ReservationSummary]
    let recentReviews: [ReviewSummary]
    let alertsAndNotifications: [AlertNotification]
    
    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case statistics
        case revenueChart = "revenue_chart"
        case userGrowthChart = "user_growth_chart"
        case serviceDistribution = "service_distribution"
        case recentReservations = "recent_reservations"
        case recentReviews = "recent_reviews"
        case alertsAndNotifications = "alerts_and_notifications"
    }
}

struct DashboardStatistics: Codable {
    let totalRevenue: Double
    let newUsers: Int
    let activeReservations: Int
    let completedServices: Int
    let totalTechnicians: Int
    let averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case totalRevenue = "total_revenue"
        case newUsers = "new_users"
        case activeReservations = "active_reservations"
        case completedServices = "completed_services"
        case totalTechnicians = "total_technicians"
        case averageRating = "average_rating"
    }
}

struct ReservationSummary: Codable {
    let id: String
    let userId: Int
    let userName: String
    let serviceName: String
    let reservationDate: Date
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case serviceName = "service_name"
        case reservationDate = "reservation_date"
        case status
    }
}

struct ReviewSummary: Codable {
    let id: String
    let userId: Int
    let userName: String
    let rating: Int
    let comment: String
    let serviceName: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case rating
        case comment
        case serviceName = "service_name"
        case date
    }
}

struct AlertNotification: Codable {
    let id: String
    let type: String
    let message: String
    let severity: String
    let date: Date
    let isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case message
        case severity
        case date
        case isRead = "is_read"
    }
}

// MARK: - 오류 정의

enum ReportingError: Error {
    case invalidDateRange
    case invalidParameters
    case downloadFailed
    case invalidURL
    case invalidData
    case authRequired
    
    var localizedDescription: String {
        switch self {
        case .invalidDateRange:
            return "올바르지 않은 날짜 범위입니다."
        case .invalidParameters:
            return "올바르지 않은 매개변수입니다."
        case .downloadFailed:
            return "파일 다운로드에 실패했습니다."
        case .invalidURL:
            return "올바르지 않은 URL입니다."
        case .invalidData:
            return "올바르지 않은 데이터입니다."
        case .authRequired:
            return "인증이 필요합니다."
        }
    }
}

// MARK: - API 구현부

class ReportingAPI {
    static let shared = ReportingAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // 고객 보고서 가져오기
    func getCustomerReport(
        parameters: [String: Any],
        completion: @escaping (Result<CustomerReportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/customer"
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 기술자 보고서 가져오기
    func getTechnicianReport(
        parameters: [String: Any],
        completion: @escaping (Result<TechnicianReportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/technician"
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 매출 보고서 가져오기
    func getRevenueReport(
        parameters: [String: Any],
        completion: @escaping (Result<RevenueReportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/revenue"
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 서비스 이용 보고서 가져오기
    func getServiceUsageReport(
        parameters: [String: Any],
        completion: @escaping (Result<ServiceUsageReportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/service-usage"
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 리뷰 및 평가 보고서 가져오기
    func getReviewsReport(
        parameters: [String: Any],
        completion: @escaping (Result<ReviewsReportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/reviews"
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 관리자 대시보드 데이터 가져오기
    func getAdminDashboard(
        completion: @escaping (Result<AdminDashboardResponse, APIError>) -> Void
    ) {
        let endpoint = "/admin/dashboard"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 관리자 대시보드 데이터 날짜 업데이트
    func updateDashboardDateRange(
        parameters: [String: Any],
        completion: @escaping (Result<AdminDashboardResponse, APIError>) -> Void
    ) {
        let endpoint = "/admin/dashboard/date-range"
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // 보고서 내보내기
    func exportReport(
        type: String,
        parameters: [String: Any],
        completion: @escaping (Result<ExportResponse, APIError>) -> Void
    ) {
        let endpoint = "/reports/\(type)/export"
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"],
            completion: completion
        )
    }
    
    // Helper to get auth token
    private func getAuthToken() -> String {
        return KeychainManager.shared.getToken(forKey: "accessToken") ?? ""
    }
}

// MARK: - 응답 모델

struct CustomerReportResponse: Codable {
    let success: Bool
    let report: CustomerReport
}

struct TechnicianReportResponse: Codable {
    let success: Bool
    let report: TechnicianReport
}

struct RevenueReportResponse: Codable {
    let success: Bool
    let report: RevenueReport
}

struct ServiceUsageReportResponse: Codable {
    let success: Bool
    let report: ServiceUsageReport
}

struct ReviewsReportResponse: Codable {
    let success: Bool
    let report: ReviewsReport
}

struct AdminDashboardResponse: Codable {
    let success: Bool
    let dashboard: ReportingDashboardData
}

struct ExportResponse: Codable {
    let success: Bool
    let downloadURL: String
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case success
        case downloadURL = "download_url"
        case expiresAt = "expires_at"
    }
}