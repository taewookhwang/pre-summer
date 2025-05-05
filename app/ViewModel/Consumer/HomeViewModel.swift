//
//  HomeViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class HomeViewModel {
    // 상태 관리를 위한 열거형
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    
    // 서비스 목록
    private(set) var featuredServices: [Service] = []
    private(set) var recentReservations: [Reservation] = []
    private(set) var categories: [ServiceCategory] = []
    
    // 상태
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // 콜백
    var stateDidChange: (() -> Void)?
    var servicesDidLoad: (() -> Void)?
    var reservationsDidLoad: (() -> Void)?
    var categoriesDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // 서비스
    private let serviceRepository = ServiceRepository.shared
    private let reservationRepository = ReservationRepository.shared
    
    // MARK: - Init
    
    init() {
        // 초기화 시 필요한 설정
    }
    
    // MARK: - Methods
    
    func loadHomeData() {
        state = .loading
        
        // 병렬로 여러 API 호출 수행
        let group = DispatchGroup()
        
        // 추천 서비스 로드
        group.enter()
        loadFeaturedServices { [weak self] in
            self?.servicesDidLoad?()
            group.leave()
        }
        
        // 최근 예약 로드
        group.enter()
        loadRecentReservations { [weak self] in
            self?.reservationsDidLoad?()
            group.leave()
        }
        
        // 카테고리 로드
        group.enter()
        loadCategories { [weak self] in
            self?.categoriesDidLoad?()
            group.leave()
        }
        
        // 모든 API 호출이 완료되면 상태 업데이트
        group.notify(queue: .main) { [weak self] in
            self?.state = .loaded
        }
    }
    
    private func loadFeaturedServices(completion: @escaping () -> Void) {
        serviceRepository.getFeaturedServices { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let services):
                    self?.featuredServices = services
                    completion()
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
    
    private func loadRecentReservations(completion: @escaping () -> Void) {
        reservationRepository.getRecentReservations { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reservations):
                    self?.recentReservations = reservations
                    completion()
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
    
    private func loadCategories(completion: @escaping () -> Void) {
        serviceRepository.getServiceCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    completion()
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                    self?.errorDidOccur?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
    
    // 검색 화면으로 이동 요청
    func requestSearchScreen() -> Bool {
        // 추가 로직이 필요한 경우 여기에 구현
        return true
    }
    
    // 카테고리 선택 처리
    func selectCategory(_ category: ServiceCategory) -> ServiceCategory {
        // 카테고리 선택 시 수행할 로직
        return category
    }
    
    // 예약 상세 화면으로 이동 요청
    func requestReservationDetails(at index: Int) -> Reservation? {
        guard index >= 0, index < recentReservations.count else {
            return nil
        }
        return recentReservations[index]
    }
    
    // 서비스 상세 화면으로 이동 요청
    func requestServiceDetails(at index: Int) -> Service? {
        guard index >= 0, index < featuredServices.count else {
            return nil
        }
        return featuredServices[index]
    }
}
