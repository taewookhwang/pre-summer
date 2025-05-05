//
//  DashboardViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class DashboardViewModel {
    // 상태 관리를 위한 열거형
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    
    // 대시보드 데이터
    private(set) var activeUsers: Int = 0
    private(set) var pendingReservations: Int = 0
    private(set) var completedServices: Int = 0
    private(set) var totalRevenue: Double = 0.0
    
    // 상태
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // 콜백
    var stateDidChange: (() -> Void)?
    var dataDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // 서비스
    private let adminService = AdminService.shared
    
    // MARK: - Methods
    
    func loadDashboardData() {
        state = .loading
        
        adminService.getDashboardData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dashboardData):
                    self?.activeUsers = dashboardData.activeUsers
                    self?.pendingReservations = dashboardData.pendingReservations
                    self?.completedServices = dashboardData.completedServices
                    self?.totalRevenue = dashboardData.totalRevenue
                    self?.state = .loaded
                    self?.dataDidLoad?()
                
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
}

