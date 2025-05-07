import Foundation

// 독립적인 ViewModel 내부 데이터 타입 사용
class DashboardViewModel {
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // 의존성
    private let reportingService = ReportingService.shared
    
    // 상태
    private(set) var viewState: ViewState = .idle
    private(set) var dashboardData: DashboardData?
    private(set) var dateRange: ReportDateRange?
    
    // 콜백
    var onViewStateChanged: ((ViewState) -> Void)?
    var onDashboardUpdated: ((DashboardData) -> Void)?
    var onDateRangeChanged: ((ReportDateRange) -> Void)?
    var onError: ((Error) -> Void)?
    
    // DashboardData 타입 정의 (외부 타입과 분리)
    struct DashboardData {
        let dateRange: ReportDateRange
        let statistics: DashboardStatistics
        let revenueChart: [ChartDataPoint]
        let userGrowthChart: [ChartDataPoint]
        let serviceDistribution: [ChartDataPoint]
        let recentReservations: [ReservationSummary]
        let recentReviews: [ReviewSummary]
        let alertsAndNotifications: [AlertNotification]
    }
    
    // MARK: - 공개 메서드
    
    // 대시보드 데이터 로드
    func loadDashboardData() {
        updateViewState(.loading)
        
        // 직접 서비스 호출을 대체할 함수 생성
        fetchAdminDashboardData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let dashboardData):
                self.dashboardData = dashboardData
                self.dateRange = dashboardData.dateRange
                
                self.updateViewState(.loaded)
                self.onDashboardUpdated?(dashboardData)
                self.onDateRangeChanged?(dashboardData.dateRange)
                
            case .failure(let error):
                self.updateViewState(.error(error.localizedDescription))
                self.onError?(error)
            }
        }
    }
    
    // 날짜 범위 업데이트
    func updateDateRange(startDate: Date, endDate: Date) {
        updateViewState(.loading)
        
        // 직접 서비스 호출을 대체할 함수 생성
        fetchDashboardWithDateRange(startDate: startDate, endDate: endDate) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let dashboardData):
                self.dashboardData = dashboardData
                self.dateRange = dashboardData.dateRange
                
                self.updateViewState(.loaded)
                self.onDashboardUpdated?(dashboardData)
                self.onDateRangeChanged?(dashboardData.dateRange)
                
            case .failure(let error):
                self.updateViewState(.error(error.localizedDescription))
                self.onError?(error)
            }
        }
    }
    
    // MARK: - 내부 도우미 메서드
    
    // 대시보드 데이터 가져오는 도우미 메서드
    private func fetchAdminDashboardData(completion: @escaping (Result<DashboardData, Error>) -> Void) {
        reportingService.getAdminDashboardData { result in
            switch result {
            case .success(let adminData):
                // 외부 타입에서 내부 타입으로 변환
                let viewModelData = DashboardData(
                    dateRange: adminData.dateRange,
                    statistics: adminData.statistics,
                    revenueChart: adminData.revenueChart,
                    userGrowthChart: adminData.userGrowthChart,
                    serviceDistribution: adminData.serviceDistribution,
                    recentReservations: adminData.recentReservations,
                    recentReviews: adminData.recentReviews,
                    alertsAndNotifications: adminData.alertsAndNotifications
                )
                completion(.success(viewModelData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 날짜 범위로 대시보드 데이터 가져오는 도우미 메서드
    private func fetchDashboardWithDateRange(startDate: Date, endDate: Date, completion: @escaping (Result<DashboardData, Error>) -> Void) {
        reportingService.updateDashboardDateRange(startDate: startDate, endDate: endDate) { result in
            switch result {
            case .success(let adminData):
                // 외부 타입에서 내부 타입으로 변환
                let viewModelData = DashboardData(
                    dateRange: adminData.dateRange,
                    statistics: adminData.statistics,
                    revenueChart: adminData.revenueChart,
                    userGrowthChart: adminData.userGrowthChart,
                    serviceDistribution: adminData.serviceDistribution,
                    recentReservations: adminData.recentReservations,
                    recentReviews: adminData.recentReviews,
                    alertsAndNotifications: adminData.alertsAndNotifications
                )
                completion(.success(viewModelData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 날짜 범위 텍스트 가져오기
    func getDateRangeText() -> String {
        guard let dateRange = dateRange else {
            return "날짜 범위 없음"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        let startDateText = formatter.string(from: dateRange.startDate)
        let endDateText = formatter.string(from: dateRange.endDate)
        
        return "\(startDateText) ~ \(endDateText)"
    }
    
    // 일간 수익 데이터 가져오기
    func getDailyRevenueData() -> [ChartDataPoint] {
        return dashboardData?.revenueChart ?? []
    }
    
    // 사용자 증가 데이터 가져오기
    func getUserGrowthData() -> [ChartDataPoint] {
        return dashboardData?.userGrowthChart ?? []
    }
    
    // 서비스 분포 데이터 가져오기
    func getServiceDistributionData() -> [ChartDataPoint] {
        return dashboardData?.serviceDistribution ?? []
    }
    
    // 최근 예약 목록 가져오기
    func getRecentReservations() -> [ReservationSummary] {
        return dashboardData?.recentReservations ?? []
    }
    
    // 최근 리뷰 목록 가져오기
    func getRecentReviews() -> [ReviewSummary] {
        return dashboardData?.recentReviews ?? []
    }
    
    // 알림 및 통지 목록 가져오기
    func getAlertsAndNotifications() -> [AlertNotification] {
        return dashboardData?.alertsAndNotifications ?? []
    }
    
    // 통계 데이터 가져오기
    func getStatistics() -> DashboardStatistics? {
        return dashboardData?.statistics
    }
    
    // 총 수익 텍스트 가져오기
    func getTotalRevenueText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "₩0"
        }
        
        // 통화 포맷팅
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KRW"
        formatter.currencySymbol = "₩"
        
        return formatter.string(from: NSNumber(value: statistics.totalRevenue)) ?? "₩\(statistics.totalRevenue)"
    }
    
    // 새 사용자 수 텍스트 가져오기
    func getNewUsersText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "0명"
        }
        
        return "\(statistics.newUsers)명"
    }
    
    // 활성 예약 수 텍스트 가져오기
    func getActiveReservationsText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "0건"
        }
        
        return "\(statistics.activeReservations)건"
    }
    
    // 완료된 서비스 수 텍스트 가져오기
    func getCompletedServicesText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "0건"
        }
        
        return "\(statistics.completedServices)건"
    }
    
    // 총 기술자 수 텍스트 가져오기
    func getTotalTechniciansText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "0명"
        }
        
        return "\(statistics.totalTechnicians)명"
    }
    
    // 평균 평점 텍스트 가져오기
    func getAverageRatingText() -> String {
        guard let statistics = dashboardData?.statistics else {
            return "0.0"
        }
        
        return String(format: "%.1f", statistics.averageRating)
    }
    
    // MARK: - 내부 도우미 메서드
    
    // 뷰 상태 업데이트
    private func updateViewState(_ state: ViewState) {
        viewState = state
        onViewStateChanged?(state)
    }
    
    // 오늘, 이번 주, 이번 달, 지난 달, 지난 분기, 올해, 작년 날짜 범위 계산
    func calculateDateRange(for rangeType: DateRangeType) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        switch rangeType {
        case .today:
            return (
                startDate: calendar.startOfDay(for: today),
                endDate: calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
            )
            
        case .thisWeek:
            let weekday = calendar.component(.weekday, from: today)
            let daysToSubtract = weekday - 1 // 일요일이 1
            
            let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: today))!
            let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            
            return (startDate: startDate, endDate: adjustedEndDate)
            
        case .thisMonth:
            let components = calendar.dateComponents([.year, .month], from: today)
            let startDate = calendar.date(from: components)!
            
            var nextMonthComponents = DateComponents()
            nextMonthComponents.month = 1
            nextMonthComponents.day = -1
            
            let endDate = calendar.date(byAdding: nextMonthComponents, to: startDate)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            
            return (startDate: startDate, endDate: adjustedEndDate)
            
        case .lastMonth:
            let currentMonthComponents = calendar.dateComponents([.year, .month], from: today)
            let currentMonthStart = calendar.date(from: currentMonthComponents)!
            
            let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)!
            let previousMonthEnd = calendar.date(byAdding: .day, value: -1, to: currentMonthStart)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: previousMonthEnd)!
            
            return (startDate: previousMonthStart, endDate: adjustedEndDate)
            
        case .lastQuarter:
            let currentMonth = calendar.component(.month, from: today)
            let currentQuarter = (currentMonth - 1) / 3 + 1
            let previousQuarter = currentQuarter - 1 > 0 ? currentQuarter - 1 : 4
            
            var startComponents = calendar.dateComponents([.year], from: today)
            startComponents.month = (previousQuarter - 1) * 3 + 1
            startComponents.day = 1
            
            // 이전 분기가 작년 4분기이면 년도 조정
            if currentQuarter == 1 && previousQuarter == 4 {
                startComponents.year = (startComponents.year ?? 0) - 1
            }
            
            let startDate = calendar.date(from: startComponents)!
            
            var endComponents = startComponents
            endComponents.month = startComponents.month! + 2
            let tempEndDate = calendar.date(from: endComponents)!
            
            var nextMonthComponents = DateComponents()
            nextMonthComponents.month = 1
            nextMonthComponents.day = -1
            
            let endDate = calendar.date(byAdding: nextMonthComponents, to: tempEndDate)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            
            return (startDate: startDate, endDate: adjustedEndDate)
            
        case .thisYear:
            var components = calendar.dateComponents([.year], from: today)
            components.month = 1
            components.day = 1
            
            let startDate = calendar.date(from: components)!
            
            components.year = components.year! + 1
            components.day = 0
            
            let endDate = calendar.date(from: components)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            
            return (startDate: startDate, endDate: adjustedEndDate)
            
        case .lastYear:
            var components = calendar.dateComponents([.year], from: today)
            components.year = components.year! - 1
            components.month = 1
            components.day = 1
            
            let startDate = calendar.date(from: components)!
            
            components.year = components.year! + 1
            components.day = 0
            
            let endDate = calendar.date(from: components)!
            let adjustedEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            
            return (startDate: startDate, endDate: adjustedEndDate)
        }
    }
}

// 날짜 범위 타입 정의
enum DateRangeType {
    case today
    case thisWeek
    case thisMonth
    case lastMonth
    case lastQuarter
    case thisYear
    case lastYear
}