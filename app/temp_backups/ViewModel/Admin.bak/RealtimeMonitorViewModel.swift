//
//  RealtimeMonitorViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class RealtimeMonitorViewModel {
    // State management enum
    enum ViewState: Equatable {
        case idle
        case loading
        case connected
        case disconnected
        case error(String)
        
        // Custom implementation of == for comparing states
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.connected, .connected), (.disconnected, .disconnected):
                return true
            case let (.error(lhsError), .error(rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    enum JobFilter {
        case all
        case inProgress
        case onWay
        case completed
        
        var displayName: String {
            switch self {
            case .all:
                return "All"
            case .inProgress:
                return "In Progress"
            case .onWay:
                return "On Way"
            case .completed:
                return "Completed"
            }
        }
    }
    
    // MARK: - Properties
    
    // Real-time data
    private(set) var activeJobs: [Job] = []
    private(set) var filteredJobs: [Job] = []
    private(set) var technicianLocations: [Int: (latitude: Double, longitude: Double)] = [:]
    private(set) var selectedFilter: JobFilter = .all
    
    // State
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var jobsDidUpdate: (() -> Void)?
    var locationsDidUpdate: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // WebSocket manager
    private let adminDashboardSocket = AdminDashboardSocket.shared
    
    // MARK: - Init
    
    init() {
        setupAnalytics()
    }
    
    // MARK: - Methods
    
    func connect() {
        state = .loading
        
        adminDashboardSocket.connect { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.state = .connected
                    self.setupListeners()
                    self.logMonitorViewEvent(action: "connect")
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                    Logger.error("Realtime monitor connection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func disconnect() {
        adminDashboardSocket.disconnect()
        state = .disconnected
        logMonitorViewEvent(action: "disconnect")
    }
    
    func setJobFilter(_ filter: JobFilter) {
        selectedFilter = filter
        applyFilters()
    }
    
    private func applyFilters() {
        switch selectedFilter {
        case .all:
            filteredJobs = activeJobs
        case .inProgress:
            filteredJobs = activeJobs.filter { $0.status == .inProgress }
        case .onWay:
            filteredJobs = activeJobs.filter { $0.status == .onWay }
        case .completed:
            filteredJobs = activeJobs.filter { $0.status == .completed }
        }
        
        jobsDidUpdate?()
    }
    
    private func setupListeners() {
        // Subscribe to job status change events
        adminDashboardSocket.onJobUpdate = { [weak self] jobs in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Check for changed jobs
                let oldIds = Set(self.activeJobs.map { $0.id })
                let newIds = Set(jobs.map { $0.id })
                
                // Check for completed jobs
                let completedJobs = jobs.filter { job in
                    job.status == .completed && 
                    self.activeJobs.first(where: { $0.id == job.id })?.status != .completed 
                }
                
                self.activeJobs = jobs
                self.applyFilters()
                
                // If new jobs were added
                if !newIds.isSubset(of: oldIds) {
                    self.logJobsAddedEvent(count: newIds.subtracting(oldIds).count)
                }
                
                // If jobs were completed
                if !completedJobs.isEmpty {
                    self.logJobsCompletedEvent(count: completedJobs.count)
                }
            }
        }
        
        // Subscribe to technician location update events
        adminDashboardSocket.onLocationUpdate = { [weak self] techId, location in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.technicianLocations[techId] = location
                self.locationsDidUpdate?()
                
                // Send analytics event periodically (since location updates can be frequent)
                if Int(Date().timeIntervalSince1970) % 60 == 0 {
                    self.logLocationUpdatesEvent(count: self.technicianLocations.count)
                }
            }
        }
        
        // Subscribe to disconnection events
        adminDashboardSocket.onDisconnect = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.state = .disconnected
                self.logMonitorViewEvent(action: "connection_lost")
            }
        }
    }
    
    func getJobsByStatus() -> [JobStatus: Int] {
        var counts: [JobStatus: Int] = [:]
        
        for job in activeJobs {
            counts[job.status, default: 0] += 1
        }
        
        return counts
    }
    
    func getTechnicianWithLocation() -> [Int] {
        return Array(technicianLocations.keys)
    }
    
    // MARK: - Analytics
    
    private func setupAnalytics() {
        // Track initialization of real-time monitor
        logMonitorViewEvent(action: "initialize")
    }
    
    private func logMonitorViewEvent(action: String) {
        let event = RealtimeMonitorEvent(
            action: action,
            activeJobsCount: activeJobs.count,
            technicianLocationCount: technicianLocations.count
        )
        
        AnalyticsManager.trackBusinessEvent(event)
    }
    
    private func logJobsAddedEvent(count: Int) {
        let event = JobsAddedEvent(count: count)
        AnalyticsManager.trackBusinessEvent(event)
    }
    
    private func logJobsCompletedEvent(count: Int) {
        let event = JobsCompletedEvent(count: count)
        AnalyticsManager.trackBusinessEvent(event)
    }
    
    private func logLocationUpdatesEvent(count: Int) {
        let event = LocationUpdatesEvent(count: count)
        AnalyticsManager.trackBusinessEvent(event)
    }
}

// MARK: - Analytics Events

struct RealtimeMonitorEvent: BusinessEvent {
    let action: String
    let activeJobsCount: Int
    let technicianLocationCount: Int
    
    var name: String {
        return "realtime_monitor_view"
    }
    
    var parameters: [String: Any] {
        return [
            "action": action,
            "active_jobs_count": activeJobsCount,
            "technician_location_count": technicianLocationCount,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

struct JobsAddedEvent: BusinessEvent {
    let count: Int
    
    var name: String {
        return "jobs_added"
    }
    
    var parameters: [String: Any] {
        return [
            "count": count,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

struct JobsCompletedEvent: BusinessEvent {
    let count: Int
    
    var name: String {
        return "jobs_completed"
    }
    
    var parameters: [String: Any] {
        return [
            "count": count,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

struct LocationUpdatesEvent: BusinessEvent {
    let count: Int
    
    var name: String {
        return "location_updates"
    }
    
    var parameters: [String: Any] {
        return [
            "count": count,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}