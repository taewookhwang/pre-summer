import Foundation

class DashboardViewModel {
    // MARK: - Types
    
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        // Custom implementation of == for comparing states
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
                return true
            case let (.error(lhsError), .error(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    // Dashboard data
    private(set) var activeUsers: Int = 0
    private(set) var pendingReservations: Int = 0
    private(set) var completedServices: Int = 0
    private(set) var totalRevenue: Double = 0.0
    
    // Hourly data
    private(set) var hourlyData: [(hour: Int, count: Int)] = []
    
    // State
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var dataDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // Service
    private let adminService = AdminService.shared
    
    // MARK: - Init
    
    init() {
        // Configuration needed at initialization
    }
    
    // MARK: - Methods
    
    func loadDashboardData() {
        state = .loading
        
        adminService.getDashboardData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let dashboardData):
                    self.activeUsers = dashboardData.activeUsers
                    self.pendingReservations = dashboardData.pendingReservations
                    self.completedServices = dashboardData.completedServices
                    self.totalRevenue = dashboardData.totalRevenue
                    self.state = .loaded
                    self.dataDidLoad?()
                    
                    // Log analytics event on success
                    self.logDashboardViewEvent()
                    
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    func loadHourlyData(forDay date: Date = Date()) {
        state = .loading
        
        adminService.getHourlyServiceData(date: date) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let hourlyData):
                    self.hourlyData = hourlyData
                    self.state = .loaded
                    self.dataDidLoad?()
                    
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Analytics
    
    private func logDashboardViewEvent() {
        // Log admin dashboard view event
        let event = AdminDashboardViewEvent(
            activeUsers: activeUsers,
            pendingReservations: pendingReservations,
            completedServices: completedServices
        )
        
        AnalyticsManager.trackBusinessEvent(event)
    }
}

// MARK: - Analytics Event

struct AdminDashboardViewEvent: BusinessEvent {
    let activeUsers: Int
    let pendingReservations: Int
    let completedServices: Int
    
    var name: String {
        return "admin_dashboard_view"
    }
    
    var parameters: [String: Any] {
        return [
            "active_users": activeUsers,
            "pending_reservations": pendingReservations,
            "completed_services": completedServices,
            "view_timestamp": Date().timeIntervalSince1970
        ]
    }
}