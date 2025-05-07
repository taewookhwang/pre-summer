//
//  UserManagementViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class UserManagementViewModel {
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
    
    enum UserRole: String, CaseIterable {
        case all = "all"
        case consumer = "consumer"
        case technician = "technician"
        case admin = "admin"
        
        var displayName: String {
            switch self {
            case .all: return "All"
            case .consumer: return "Consumer"
            case .technician: return "Technician"
            case .admin: return "Admin"
            }
        }
    }
    
    // MARK: - Properties
    
    // User list
    private(set) var users: [AppUser] = []
    private(set) var filteredUsers: [AppUser] = []
    private(set) var selectedRole: UserRole = .all
    private(set) var searchText: String = ""
    
    // State
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var usersDidLoad: (() -> Void)?
    var filteredUsersDidChange: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // Service
    private let adminService = AdminService.shared
    
    // MARK: - Methods
    
    func loadUsers() {
        state = .loading
        
        adminService.getUserList { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    self.state = .loaded
                    self.usersDidLoad?()
                    self.applyFilters()
                    
                    // Analytics event for successful loading
                    self.logUserManagementViewEvent()
                    
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                    
                    // Error logging
                    Logger.error("Failed to load user list: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateUserStatus(userId: Int, isActive: Bool, completion: @escaping (Bool) -> Void) {
        adminService.updateUserStatus(userId: userId, isActive: isActive) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success {
                        // Refresh user list after successful status update
                        self.logUserStatusUpdateEvent(userId: userId, isActive: isActive)
                        self.loadUsers()
                    }
                    completion(success)
                case .failure(let error):
                    Logger.error("Failed to update user status: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func setRoleFilter(_ role: UserRole) {
        selectedRole = role
        applyFilters()
    }
    
    func setSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    private func applyFilters() {
        // Role filtering
        var filtered = users
        if selectedRole != .all {
            filtered = users.filter { $0.role == selectedRole.rawValue }
        }
        
        // Search text filtering
        if !searchText.isEmpty {
            filtered = filtered.filter { user in
                let nameMatch = user.name?.lowercased().contains(searchText.lowercased()) ?? false
                let emailMatch = user.email.lowercased().contains(searchText.lowercased())
                let phoneMatch = user.phone?.contains(searchText) ?? false
                
                return nameMatch || emailMatch || phoneMatch
            }
        }
        
        filteredUsers = filtered
        filteredUsersDidChange?()
    }
    
    func getUsersByRole() -> [UserRole: Int] {
        var counts: [UserRole: Int] = [:]
        
        for role in UserRole.allCases {
            if role == .all {
                counts[role] = users.count
            } else {
                counts[role] = users.filter { $0.role == role.rawValue }.count
            }
        }
        
        return counts
    }
    
    // MARK: - Analytics
    
    private func logUserManagementViewEvent() {
        let event = UserManagementViewEvent(
            totalUsers: users.count,
            consumerCount: users.filter { $0.role == "consumer" }.count,
            technicianCount: users.filter { $0.role == "technician" }.count
        )
        
        AnalyticsManager.trackBusinessEvent(event)
    }
    
    private func logUserStatusUpdateEvent(userId: Int, isActive: Bool) {
        let event = UserStatusUpdateEvent(
            userId: userId,
            newStatus: isActive ? "active" : "inactive"
        )
        
        AnalyticsManager.trackBusinessEvent(event)
    }
}

// MARK: - Analytics Events

struct UserManagementViewEvent: BusinessEvent {
    let totalUsers: Int
    let consumerCount: Int
    let technicianCount: Int
    
    var name: String {
        return "user_management_view"
    }
    
    var parameters: [String: Any] {
        return [
            "total_users": totalUsers,
            "consumer_count": consumerCount,
            "technician_count": technicianCount,
            "view_timestamp": Date().timeIntervalSince1970
        ]
    }
}

struct UserStatusUpdateEvent: BusinessEvent {
    let userId: Int
    let newStatus: String
    
    var name: String {
        return "user_status_update"
    }
    
    var parameters: [String: Any] {
        return [
            "user_id": userId,
            "new_status": newStatus,
            "update_timestamp": Date().timeIntervalSince1970
        ]
    }
}

