//
//  UserManagementViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class UserManagementViewModel {
    // 상태 관리를 위한 열거형
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    
    // 사용자 목록
    private(set) var users: [User] = []
    
    // 상태
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // 콜백
    var stateDidChange: (() -> Void)?
    var usersDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // 서비스
    private let adminService = AdminService.shared
    
    // MARK: - Methods
    
    func loadUsers() {
        state = .loading
        
        adminService.getUserList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.state = .loaded
                    self?.usersDidLoad?()
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUserStatus(userId: Int, isActive: Bool, completion: @escaping (Bool) -> Void) {
        adminService.updateUserStatus(userId: userId, isActive: isActive) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success {
                        // 사용자 상태 업데이트 성공 시 목록 새로고침
                        self?.loadUsers()
                    }
                    completion(success)
                case .failure:
                    completion(false)
                }
            }
        }
    }
}

