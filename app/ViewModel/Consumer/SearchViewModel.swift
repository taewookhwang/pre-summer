//
//  SearchViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class SearchViewModel {
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
    private(set) var searchResults: [Service] = []
    private(set) var selectedCategory: ServiceCategory?
    
    // Pagination
    private(set) var pagination: PaginationMeta?
    private(set) var currentPage: Int = 1
    private(set) var searchQuery: String = ""
    
    // State
    private(set) var state: ViewState = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var searchResultsDidLoad: (() -> Void)?
    var loadMoreDidComplete: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // Services
    private let serviceRepository = ServiceRepository.shared
    
    // MARK: - Init
    
    init() {
        // Settings required during initialization
    }
    
    // MARK: - Methods
    
    func search(query: String) {
        currentPage = 1
        searchQuery = query
        state = .loading
        
        serviceRepository.searchServices(query: query, page: currentPage) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.searchResults = response.0
                    self.pagination = response.1
                    self.state = .loaded
                    self.searchResultsDidLoad?()
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    func searchByCategory(category: ServiceCategory) {
        selectedCategory = category
        currentPage = 1
        state = .loading
        
        let filter = ServiceFilter(category: category.id)
        serviceRepository.getServices(with: filter, page: currentPage) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.searchResults = response.0
                    self.pagination = response.1
                    self.state = .loaded
                    self.searchResultsDidLoad?()
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                    self.errorDidOccur?(error.localizedDescription)
                }
            }
        }
    }
    
    func loadMore() {
        guard let pagination = pagination, pagination.hasNextPage else { return }
        
        currentPage += 1
        
        // 기존 검색어가 있는 경우
        if !searchQuery.isEmpty {
            serviceRepository.searchServices(query: searchQuery, page: currentPage) { [weak self] result in
                self?.handleLoadMoreResult(result)
            }
        }
        // 카테고리로 검색하는 경우
        else if let category = selectedCategory {
            let filter = ServiceFilter(category: category.id)
            serviceRepository.getServices(with: filter, page: currentPage) { [weak self] result in
                self?.handleLoadMoreResult(result)
            }
        }
    }
    
    private func handleLoadMoreResult(_ result: Result<([Service], PaginationMeta?), Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.searchResults.append(contentsOf: response.0)
                self.pagination = response.1
                self.loadMoreDidComplete?()
            case .failure(let error):
                self.errorDidOccur?(error.localizedDescription)
                // 페이지 증가를 원래대로 되돌립니다
                self.currentPage -= 1
            }
        }
    }
    
    func getService(at index: Int) -> Service? {
        guard index >= 0, index < searchResults.count else {
            return nil
        }
        return searchResults[index]
    }
}
