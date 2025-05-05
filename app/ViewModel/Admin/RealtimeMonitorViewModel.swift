//
//  RealtimeMonitorViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class RealtimeMonitorViewModel {
    // 상태 관리를 위한 열거형
    enum ViewState {
        case idle
        case loading
        case connected
        case disconnected
        case error(String)
    }
    
    // MARK: - Properties
    
    // 실시간 데이터
    private(set) var activeJobs: [Job] = []
    private(set) var technicianLocations: [Int: (latitude: Double, longitude: Double)] = [:]
    
    // 상태
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // 콜백
    var stateDidChange: (() -> Void)?
    var jobsDidUpdate: (() -> Void)?
    var locationsDidUpdate: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // 웹소켓 매니저 (실제 구현은 WebSocketManager 사용 예정)
    private let adminDashboardSocket = AdminDashboardSocket.shared
    
    // MARK: - Methods
    
    func connect() {
        state = .loading
        
        adminDashboardSocket.connect { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.state = .connected
                    self?.setupListeners()
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    func disconnect() {
        adminDashboardSocket.disconnect()
        state = .disconnected
    }
    
    private func setupListeners() {
        // 작업 상태 변경 이벤트 구독
        adminDashboardSocket.onJobUpdate = { [weak self] jobs in
            DispatchQueue.main.async {
                self?.activeJobs = jobs
                self?.jobsDidUpdate?()
            }
        }
        
        // 기술자 위치 업데이트 이벤트 구독
        adminDashboardSocket.onLocationUpdate = { [weak self] techId, location in
            DispatchQueue.main.async {
                self?.technicianLocations[techId] = location
                self?.locationsDidUpdate?()
            }
        }
        
        // 연결 끊김 이벤트 구독
        adminDashboardSocket.onDisconnect = { [weak self] in
            DispatchQueue.main.async {
                self?.state = .disconnected
            }
        }
    }
}

