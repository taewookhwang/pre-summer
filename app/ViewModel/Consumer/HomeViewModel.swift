//
//  HomeViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class HomeViewModel {
    // State management enum
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
    
    // Service lists
    private(set) var featuredServices: [Service] = []
    private(set) var recentReservations: [Reservation] = []
    private(set) var categories: [ServiceCategory] = []
    
    // Pagination
    private(set) var servicesPagination: Data.Models.PaginationMeta?
    private(set) var reservationsPagination: Data.Models.PaginationMeta?
    private(set) var currentServicesPage: Int = 1
    private(set) var currentReservationsPage: Int = 1
    
    // State
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var servicesDidLoad: (() -> Void)?
    var reservationsDidLoad: (() -> Void)?
    var categoriesDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    var loadMoreServicesDidComplete: (() -> Void)?
    var loadMoreReservationsDidComplete: (() -> Void)?
    
    // Services
    private let serviceRepository = ServiceRepository.shared
    private let reservationRepository = ReservationRepository.shared
    
    // MARK: - Init
    
    init() {
        // Settings required during initialization
    }
    
    // MARK: - Methods
    
    func loadHomeData() {
        state = .loading
        
        // Perform multiple API calls in parallel
        let group = DispatchGroup()
        
        // Load featured services
        group.enter()
        loadFeaturedServices { [weak self] in
            self?.servicesDidLoad?()
            group.leave()
        }
        
        // Load recent reservations
        group.enter()
        loadRecentReservations { [weak self] in
            self?.reservationsDidLoad?()
            group.leave()
        }
        
        // Load categories
        group.enter()
        loadCategories { [weak self] in
            self?.categoriesDidLoad?()
            group.leave()
        }
        
        // Update state when all API calls are completed
        group.notify(queue: .main) { [weak self] in
            self?.state = .loaded
        }
    }
    
    private func loadFeaturedServices(completion: @escaping () -> Void) {
        serviceRepository.getFeaturedServices(page: currentServicesPage) { [weak self] (result: Result<([Service], Data.Models.PaginationMeta?), Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if self.currentServicesPage == 1 {
                        self.featuredServices = response.0
                    } else {
                        self.featuredServices.append(contentsOf: response.0)
                    }
                    self.servicesPagination = response.1
                    completion()
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
    
    func loadMoreFeaturedServices() {
        guard let pagination = servicesPagination, pagination.hasNextPage else { return }
        
        currentServicesPage += 1
        serviceRepository.getFeaturedServices(page: currentServicesPage) { [weak self] (result: Result<([Service], Data.Models.PaginationMeta?), Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.featuredServices.append(contentsOf: response.0)
                    self.servicesPagination = response.1
                    self.loadMoreServicesDidComplete?()
                case .failure(let error):
                    self.errorDidOccur?(error.localizedDescription)
                    // 페이지 증가를 원래대로 되돌립니다
                    self.currentServicesPage -= 1
                }
            }
        }
    }
    
    private func loadRecentReservations(completion: @escaping () -> Void) {
        reservationRepository.getRecentReservations(page: currentReservationsPage) { [weak self] (result: Result<([Reservation], Data.Models.PaginationMeta?), Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if self.currentReservationsPage == 1 {
                        self.recentReservations = response.0
                    } else {
                        self.recentReservations.append(contentsOf: response.0)
                    }
                    self.reservationsPagination = response.1
                    completion()
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
    
    func loadMoreReservations() {
        guard let pagination = reservationsPagination, pagination.hasNextPage else { return }
        
        currentReservationsPage += 1
        reservationRepository.getRecentReservations(page: currentReservationsPage) { [weak self] (result: Result<([Reservation], Data.Models.PaginationMeta?), Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.recentReservations.append(contentsOf: response.0)
                    self.reservationsPagination = response.1
                    self.loadMoreReservationsDidComplete?()
                case .failure(let error):
                    self.errorDidOccur?(error.localizedDescription)
                    // 페이지 증가를 원래대로 되돌립니다
                    self.currentReservationsPage -= 1
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
    
    // Request to move to search screen
    func requestSearchScreen() -> Bool {
        // Implement additional logic here if needed
        return true
    }
    
    // Handle category selection
    func selectCategory(_ category: ServiceCategory) -> ServiceCategory {
        // Logic to perform when a category is selected
        return category
    }
    
    // Request to move to reservation details screen
    func requestReservationDetails(at index: Int) -> Reservation? {
        guard index >= 0, index < recentReservations.count else {
            return nil
        }
        return recentReservations[index]
    }
    
    // Request to move to service details screen
    func requestServiceDetails(at index: Int) -> Service? {
        guard index >= 0, index < featuredServices.count else {
            return nil
        }
        return featuredServices[index]
    }
}