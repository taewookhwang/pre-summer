//
//  MatchingViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class MatchingViewModel {
    // 상태 관리를 위한 열거형
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    
    // 매칭 관련 데이터
    private(set) var pendingReservations: [Reservation] = []
    private(set) var availableTechnicians: [User] = []
    
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
    
    func loadMatchingData() {
        state = .loading
        
        // 실제 구현에서는 AdminService를 통해 API 호출
        // 지금은 더미 데이터로 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.pendingReservations = []
            self.availableTechnicians = []
            self.state = .loaded
            self.dataDidLoad?()
        }
    }
    
    func assignTechnician(reservationId: Int, technicianId: Int, completion: @escaping (Bool) -> Void) {
        // 실제 구현에서는 AdminService를 통해 API 호출
        // 지금은 항상 성공하도록 구현
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
}

