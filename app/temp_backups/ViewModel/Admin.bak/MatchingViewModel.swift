//
//  MatchingViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class MatchingViewModel {
    // Enumeration for state management
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
    
    enum LoadingType {
        case reservations
        case technicians
        case both
    }
    
    // MARK: - Properties
    
    // Matching related data
    private(set) var pendingReservations: [Reservation] = []
    private(set) var availableTechnicians: [AppUser] = []
    
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
    
    // MARK: - Methods
    
    func loadMatchingData() {
        loadData(type: .both)
    }
    
    func refreshReservations() {
        loadData(type: .reservations)
    }
    
    func refreshTechnicians() {
        loadData(type: .technicians)
    }
    
    private func loadData(type: LoadingType) {
        state = .loading
        
        switch type {
        case .reservations:
            loadPendingReservations()
        case .technicians:
            loadAvailableTechnicians()
        case .both:
            loadPendingReservations()
            loadAvailableTechnicians()
        }
    }
    
    private func loadPendingReservations() {
        adminService.getPendingReservations { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let reservations):
                    self.pendingReservations = reservations
                    self.checkDataLoadingComplete()
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func loadAvailableTechnicians() {
        adminService.getAvailableTechnicians(date: Date()) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let technicians):
                    self.availableTechnicians = technicians
                    self.checkDataLoadingComplete()
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func checkDataLoadingComplete() {
        if state == .loading {
            state = .loaded
            dataDidLoad?()
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = error.localizedDescription
        state = .error(errorMessage)
        errorDidOccur?(errorMessage)
        
        // Error logging
        Logger.error("Failed to load matching data: \(errorMessage)")
    }
    
    func assignTechnician(reservationId: String, technicianId: Int, completion: @escaping (Bool) -> Void) {
        adminService.assignTechnician(reservationId: reservationId, technicianId: technicianId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success {
                        // Refresh list after successful matching
                        self.refreshReservations()
                    }
                    completion(success)
                case .failure(let error):
                    Logger.error("Failed to assign technician: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func getTechnicianName(by id: Int) -> String? {
        return availableTechnicians.first(where: { $0.id == id })?.name
    }
    
    func filterTechnicians(by searchText: String) -> [AppUser] {
        guard !searchText.isEmpty else {
            return availableTechnicians
        }
        
        return availableTechnicians.filter { technician in
            let nameMatch = technician.name?.lowercased().contains(searchText.lowercased()) ?? false
            let emailMatch = technician.email.lowercased().contains(searchText.lowercased())
            let phoneMatch = technician.phone?.contains(searchText) ?? false
            
            return nameMatch || emailMatch || phoneMatch
        }
    }
}