import UIKit

class HomeVC: UIViewController {
    // MARK: - Properties
    
    var viewModel: HomeViewModel!
    weak var coordinator: ConsumerCoordinator?
    
    // UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Services"
        searchBar.delegate = self
        return searchBar
    }()
    
    // 카테고리 섹션
    private lazy var categoriesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Categories"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell") // 레거시 지원
        collectionView.register(HierarchicalCategoryCell.self, forCellWithReuseIdentifier: "HierarchicalCategoryCell")
        return collectionView
    }()
    
    // 서브카테고리 섹션 (선택된 카테고리가 있을 때만 표시)
    private lazy var subcategoriesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subcategories"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.isHidden = true
        return label
    }()
    
    private lazy var subcategoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 40)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SubcategoryCell.self, forCellWithReuseIdentifier: "SubcategoryCell")
        collectionView.isHidden = true
        return collectionView
    }()
    
    // 카테고리 서비스 섹션 (선택된 카테고리가 있을 때만 표시)
    private lazy var categoryServicesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Category Services"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.isHidden = true
        return label
    }()
    
    private lazy var categoryServicesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 200)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ServiceCell.self, forCellWithReuseIdentifier: "ServiceCell")
        collectionView.isHidden = true
        return collectionView
    }()
    
    private lazy var featuredServicesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Featured Services"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var servicesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 200)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ServiceCell.self, forCellWithReuseIdentifier: "ServiceCell")
        return collectionView
    }()
    
    private lazy var recentReservationsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Recent Reservations"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var reservationsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: "ReservationCell")
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.loadData()
        }
        return view
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(
            image: UIImage(named: "no_reservations"),
            title: "No Reservations",
            message: "Your reservations will appear here when you book services"
        )
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data every time the screen appears (when reservation status changes)
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Home"
        
        // Navigation setup
        setupNavigationBar()
        
        // Add views
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 기본 컴포넌트 추가
        contentView.addSubview(searchBar)
        
        // 카테고리 섹션 추가
        contentView.addSubview(categoriesLabel)
        contentView.addSubview(categoriesCollectionView)
        
        // 서브카테고리 섹션 추가
        contentView.addSubview(subcategoriesLabel)
        contentView.addSubview(subcategoriesCollectionView)
        
        // 카테고리별 서비스 섹션 추가
        contentView.addSubview(categoryServicesLabel)
        contentView.addSubview(categoryServicesCollectionView)
        
        // 추천 서비스 섹션 추가
        contentView.addSubview(featuredServicesLabel)
        contentView.addSubview(servicesCollectionView)
        
        // 최근 예약 섹션 추가
        contentView.addSubview(recentReservationsLabel)
        contentView.addSubview(reservationsTableView)
        
        // 로딩 및 에러 표시 뷰 추가
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        view.addSubview(emptyStateView)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = profileButton
    }
    
    private func setupConstraints() {
        // Scroll view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 기본 Content view 요소들
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 카테고리 섹션
            categoriesLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 8),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            // 서브카테고리 섹션
            subcategoriesLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 24),
            subcategoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            subcategoriesCollectionView.topAnchor.constraint(equalTo: subcategoriesLabel.bottomAnchor, constant: 8),
            subcategoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subcategoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subcategoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            // 카테고리 서비스 섹션
            categoryServicesLabel.topAnchor.constraint(equalTo: subcategoriesCollectionView.bottomAnchor, constant: 24),
            categoryServicesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            categoryServicesCollectionView.topAnchor.constraint(equalTo: categoryServicesLabel.bottomAnchor, constant: 8),
            categoryServicesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryServicesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryServicesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            // 추천 서비스 섹션
            featuredServicesLabel.topAnchor.constraint(equalTo: categoryServicesCollectionView.bottomAnchor, constant: 24),
            featuredServicesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            servicesCollectionView.topAnchor.constraint(equalTo: featuredServicesLabel.bottomAnchor, constant: 8),
            servicesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            servicesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            servicesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            // 최근 예약 섹션
            recentReservationsLabel.topAnchor.constraint(equalTo: servicesCollectionView.bottomAnchor, constant: 24),
            recentReservationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            reservationsTableView.topAnchor.constraint(equalTo: recentReservationsLabel.bottomAnchor, constant: 8),
            reservationsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reservationsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reservationsTableView.heightAnchor.constraint(equalToConstant: 300),
            reservationsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // Loading and error views
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: recentReservationsLabel.bottomAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.servicesDidLoad = { [weak self] in
            self?.servicesCollectionView.reloadData()
        }
        
        viewModel.reservationsDidLoad = { [weak self] in
            self?.reservationsTableView.reloadData()
            self?.updateEmptyStateView()
        }
        
        // 레거시 카테고리 콜백
        viewModel.categoriesDidLoad = { [weak self] in
            self?.categoriesCollectionView.reloadData()
        }
        
        // 계층형 카테고리 콜백
        viewModel.hierarchicalCategoriesDidLoad = { [weak self] in
            guard let self = self else { return }
            print("📱 HomeVC: hierarchicalCategoriesDidLoad 콜백 호출됨, 카테고리 수: \(self.viewModel.hierarchicalCategories.count)")

            // UI 스레드에서 컬렉션뷰 업데이트
            DispatchQueue.main.async {
                self.categoriesCollectionView.reloadData()
                print("📱 HomeVC: categoriesCollectionView 리로드 완료")

                // collectionView의 numberOfItemsInSection 직접 확인
                let itemsCount = self.collectionView(self.categoriesCollectionView, numberOfItemsInSection: 0)
                print("📱 HomeVC: categoriesCollectionView의 아이템 수: \(itemsCount)")

                // 카테고리가 로드되면 서브카테고리 섹션은 숨김 (카테고리 선택 시 표시됨)
                self.updateSubcategorySection()
            }
        }
        
        // 카테고리 서비스 콜백
        viewModel.categoryServicesDidLoad = { [weak self] in
            self?.categoryServicesCollectionView.reloadData()
            // 선택된 카테고리의 서비스를 표시
            self?.updateCategoryServicesSection()
        }
        
        // 서브카테고리 서비스 콜백
        viewModel.subcategoryServicesDidLoad = { [weak self] in
            self?.categoryServicesCollectionView.reloadData()
            // 선택된 서브카테고리의 서비스를 표시
            self?.updateCategoryServicesSection()
        }
        
        viewModel.errorDidOccur = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    // 서브카테고리 섹션 업데이트
    private func updateSubcategorySection() {
        if let selectedCategory = viewModel.selectedCategory, let subcategories = selectedCategory.subcategories, !subcategories.isEmpty {
            subcategoriesLabel.isHidden = false
            subcategoriesCollectionView.isHidden = false
            subcategoriesCollectionView.reloadData()
        } else {
            subcategoriesLabel.isHidden = true
            subcategoriesCollectionView.isHidden = true
        }
    }
    
    // 카테고리 서비스 섹션 업데이트
    private func updateCategoryServicesSection() {
        // 카테고리가 선택되었고 서비스가 있으면 섹션 표시
        if viewModel.selectedCategory != nil && (!viewModel.categoryServices.isEmpty || !viewModel.subcategoryServices.isEmpty) {
            categoryServicesLabel.isHidden = false
            categoryServicesCollectionView.isHidden = false
            
            // 표시할 서비스 목록 설정
            if let selectedSubcategory = viewModel.selectedSubcategory, !viewModel.subcategoryServices.isEmpty {
                categoryServicesLabel.text = "\(selectedSubcategory.name) Services"
            } else if let selectedCategory = viewModel.selectedCategory, !viewModel.categoryServices.isEmpty {
                categoryServicesLabel.text = "\(selectedCategory.name) Services"
            }
        } else {
            categoryServicesLabel.isHidden = true
            categoryServicesCollectionView.isHidden = true
        }
    }
    
    // MARK: - Data
    
    private func loadData() {
        viewModel.loadHomeData()
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        switch viewModel.state {
        case .idle, .loading:
            loadingIndicator.startAnimating()
            errorView.isHidden = true
            scrollView.isHidden = true
            print("📱 HomeVC: Loading state")

        case .loaded:
            loadingIndicator.stopAnimating()
            errorView.isHidden = true
            scrollView.isHidden = false
            updateEmptyStateView()

            // 디버깅 정보 출력
            print("📱 HomeVC: Loaded state")
            print("📱 Categories count: \(viewModel.hierarchicalCategories.count)")
            print("📱 Featured services count: \(viewModel.featuredServices.count)")
            print("📱 Recent reservations count: \(viewModel.recentReservations.count)")

            // UI 가시성 로깅
            print("📱 categoriesCollectionView hidden: \(categoriesCollectionView.isHidden)")
            print("📱 servicesCollectionView hidden: \(servicesCollectionView.isHidden)")
            print("📱 reservationsTableView hidden: \(reservationsTableView.isHidden)")

            // 컬렉션뷰 강제 리로드
            DispatchQueue.main.async {
                self.categoriesCollectionView.reloadData()
                self.servicesCollectionView.reloadData()
                self.reservationsTableView.reloadData()
            }

        case .error(let message):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = true
            print("📱 HomeVC: Error state - \(message)")
            errorView.isHidden = false
            errorView.configure(message: message)
        }
    }
    
    private func updateEmptyStateView() {
        if viewModel.recentReservations.isEmpty {
            emptyStateView.isHidden = false
            reservationsTableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            reservationsTableView.isHidden = false
        }
    }
    
    // 현재 표시중인 알림이 있는지 추적하는 변수
    private var isShowingAlert = false
    
    private func showErrorAlert(message: String) {
        // 이미 알림이 표시 중이거나 다른 알림 컨트롤러가 표시 중인 경우 새 알림을 표시하지 않음
        if isShowingAlert || presentedViewController is UIAlertController {
            print("Alert already presented, skipping new alert with message: \(message)")
            return
        }

        isShowingAlert = true

        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "확인",
            style: .default,
            handler: { [weak self] _ in
                self?.isShowingAlert = false
            }
        ))

        // 현재 화면에 표시된 알림이 없을 때만 새 알림 표시
        if presentedViewController == nil {
            present(alert, animated: true)
        }
    }

    // 서비스 상세 정보를 로드하고 요청 화면으로 이동하는 메서드
    private func loadServiceDetailAndShowRequest(serviceId: String) {
        // 로딩 표시
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)

        // 서비스 상세 정보 로드
        let serviceDetailViewModel = ServiceDetailViewModel(serviceId: serviceId)
        serviceDetailViewModel.stateDidChange = { [weak self, weak loadingIndicator] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                loadingIndicator?.removeFromSuperview()

                switch serviceDetailViewModel.state {
                case .loaded:
                    // 서비스 상세 정보가 로드되면 요청 화면으로 이동
                    self.coordinator?.showRequestService(serviceDetail: serviceDetailViewModel.serviceDetail)
                case .error(let errorMessage):
                    // 에러 발생 시 알림 표시
                    self.showErrorAlert(message: "서비스 상세 정보를 불러올 수 없습니다: \(errorMessage)")
                default:
                    break
                }
            }
        }

        // 서비스 상세 정보 로드 시작
        serviceDetailViewModel.loadServiceDetail()
    }

    // MARK: - Actions

    @objc private func profileButtonTapped() {
        coordinator?.showProfile()
    }
}

// MARK: - UISearchBarDelegate

extension HomeVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if viewModel.requestSearchScreen() {
            coordinator?.showSearch()
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            // 계층형 카테고리가 있으면 그것을 사용, 아니면 레거시 카테고리 사용
            let count = !viewModel.hierarchicalCategories.isEmpty ? viewModel.hierarchicalCategories.count : viewModel.categories.count
            print("📱 HomeVC: categoriesCollectionView의 numberOfItemsInSection 호출, 반환할 아이템 수: \(count)")
            print("📱 HomeVC: 계층형 카테고리 수: \(viewModel.hierarchicalCategories.count), 레거시 카테고리 수: \(viewModel.categories.count)")
            return count
        } else if collectionView == subcategoriesCollectionView {
            if let selectedCategory = viewModel.selectedCategory, let subcategories = selectedCategory.subcategories {
                print("📱 HomeVC: subcategoriesCollectionView의 numberOfItemsInSection 호출, 반환할 아이템 수: \(subcategories.count)")
                return subcategories.count
            }
            print("📱 HomeVC: subcategoriesCollectionView의 numberOfItemsInSection 호출, 반환할 아이템 수: 0")
            return 0
        } else if collectionView == categoryServicesCollectionView {
            // 서브카테고리가 선택되었으면 서브카테고리 서비스, 아니면 카테고리 서비스
            if viewModel.selectedSubcategory != nil {
                print("📱 HomeVC: categoryServicesCollectionView의 numberOfItemsInSection 호출, 서브카테고리 서비스 수: \(viewModel.subcategoryServices.count)")
                return viewModel.subcategoryServices.count
            } else {
                print("📱 HomeVC: categoryServicesCollectionView의 numberOfItemsInSection 호출, 카테고리 서비스 수: \(viewModel.categoryServices.count)")
                return viewModel.categoryServices.count
            }
        } else {
            // 기본 서비스 컬렉션뷰 (추천 서비스)
            print("📱 HomeVC: servicesCollectionView의 numberOfItemsInSection 호출, 추천 서비스 수: \(viewModel.featuredServices.count)")
            return viewModel.featuredServices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            // 계층형 카테고리 표시
            if !viewModel.hierarchicalCategories.isEmpty {
                print("📱 HomeVC: cellForItemAt - 계층형 카테고리 셀 생성: \(indexPath.item)")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HierarchicalCategoryCell", for: indexPath) as! HierarchicalCategoryCell
                let category = viewModel.hierarchicalCategories[indexPath.item]
                print("📱 HomeVC: 카테고리 셀 데이터 - 이름: \(category.name), ID: \(category.id)")
                cell.configure(with: category)
                return cell
            } else {
                // 레거시 카테고리 표시 (백엔드가 준비되지 않은 경우 폴백)
                print("📱 HomeVC: cellForItemAt - 레거시 카테고리 셀 생성: \(indexPath.item)")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
                let category = viewModel.categories[indexPath.item]
                print("📱 HomeVC: 레거시 카테고리 셀 데이터 - 이름: \(category.name), ID: \(category.id)")
                cell.configure(with: category)
                return cell
            }
        } else if collectionView == subcategoriesCollectionView {
            print("📱 HomeVC: cellForItemAt - 서브카테고리 셀 생성: \(indexPath.item)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubcategoryCell", for: indexPath) as! SubcategoryCell
            if let selectedCategory = viewModel.selectedCategory, let subcategories = selectedCategory.subcategories {
                let subcategory = subcategories[indexPath.item]
                print("📱 HomeVC: 서브카테고리 셀 데이터 - 이름: \(subcategory.name), ID: \(subcategory.id)")
                cell.configure(with: subcategory)
            }
            return cell
        } else if collectionView == categoryServicesCollectionView {
            print("📱 HomeVC: cellForItemAt - 카테고리 서비스 셀 생성: \(indexPath.item)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            // 서브카테고리가 선택되었으면 서브카테고리 서비스, 아니면 카테고리 서비스
            if viewModel.selectedSubcategory != nil {
                let service = viewModel.subcategoryServices[indexPath.item]
                print("📱 HomeVC: 서브카테고리 서비스 셀 데이터 - 이름: \(service.name), ID: \(service.id)")
                cell.configure(with: service)
            } else {
                let service = viewModel.categoryServices[indexPath.item]
                print("📱 HomeVC: 카테고리 서비스 셀 데이터 - 이름: \(service.name), ID: \(service.id)")
                cell.configure(with: service)
            }
            return cell
        } else {
            // 기본 서비스 컬렉션뷰 (추천 서비스)
            print("📱 HomeVC: cellForItemAt - 추천 서비스 셀 생성: \(indexPath.item)")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            let service = viewModel.featuredServices[indexPath.item]
            print("📱 HomeVC: 추천 서비스 셀 데이터 - 이름: \(service.name), ID: \(service.id)")
            cell.configure(with: service)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            if !viewModel.hierarchicalCategories.isEmpty {
                // 계층형 카테고리 선택 처리
                let category = viewModel.hierarchicalCategories[indexPath.item]
                let _ = viewModel.selectHierarchicalCategory(category)
                
                // 선택된 카테고리의 서비스 로드
                viewModel.loadServicesByCategory(category) {
                    // 콜백은 viewModel의 categoryServicesDidLoad에서 처리됨
                }
                
                // 서브카테고리 섹션 업데이트
                updateSubcategorySection()
            } else {
                // 레거시 카테고리 선택 처리
                let category = viewModel.categories[indexPath.item]
                let _ = viewModel.selectCategory(category)
                
                // 레거시 처리: 검색 화면으로 이동
                coordinator?.showSearch()
            }
        } else if collectionView == subcategoriesCollectionView {
            // 서브카테고리 선택 처리
            if let selectedCategory = viewModel.selectedCategory, let subcategories = selectedCategory.subcategories {
                let subcategory = subcategories[indexPath.item]
                viewModel.selectSubcategory(subcategory)
                
                // 선택된 서브카테고리의 서비스 로드
                viewModel.loadServicesBySubcategory(subcategory) {
                    // 콜백은 viewModel의 subcategoryServicesDidLoad에서 처리됨
                }
            }
        } else if collectionView == categoryServicesCollectionView {
            // 카테고리 서비스 선택 처리
            if viewModel.selectedSubcategory != nil {
                if let service = viewModel.requestSubcategoryServiceDetails(at: indexPath.item) {
                    // 서비스 상세 정보를 로드하고 요청 화면으로 이동
                    loadServiceDetailAndShowRequest(serviceId: service.id)
                }
            } else {
                if let service = viewModel.requestCategoryServiceDetails(at: indexPath.item) {
                    // 서비스 상세 정보를 로드하고 요청 화면으로 이동
                    loadServiceDetailAndShowRequest(serviceId: service.id)
                }
            }
        } else {
            // 기본 서비스 선택 처리 (추천 서비스)
            if let service = viewModel.requestServiceDetails(at: indexPath.item) {
                // 서비스 상세 정보를 로드하고 요청 화면으로 이동
                loadServiceDetailAndShowRequest(serviceId: service.id)
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recentReservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationCell
        let reservation = viewModel.recentReservations[indexPath.row]
        cell.configure(with: reservation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let reservation = viewModel.requestReservationDetails(at: indexPath.row) {
            // Navigate to reservation details screen when reservation is selected (not implemented)
            // coordinator?.showReservationDetail(reservation: reservation)
        }
    }
}

// MARK: - Custom Cells

class CategoryCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with category: ServiceCategory) {
        titleLabel.text = category.name
        
        if let imageURLString = category.imageURL, let url = URL(string: imageURLString) {
            // Using regular URLSession instead of image libraries (e.g., Kingfisher, SDWebImage)
            // Using URLSession for implementation convenience
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "questionmark.circle")
        }
    }
}

class ServiceCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemBlue
        return label
    }()
    
    private let ratingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(ratingView)
        
        ratingView.addSubview(ratingImageView)
        ratingView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            ratingView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            ratingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            ratingView.heightAnchor.constraint(equalToConstant: 20),
            
            ratingImageView.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor),
            ratingImageView.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            ratingImageView.widthAnchor.constraint(equalToConstant: 16),
            ratingImageView.heightAnchor.constraint(equalToConstant: 16),
            
            ratingLabel.leadingAnchor.constraint(equalTo: ratingImageView.trailingAnchor, constant: 4),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor)
        ])
    }
    
    func configure(with service: Service) {
        titleLabel.text = service.name
        priceLabel.text = "\(service.priceValue.formattedPrice()) KRW"
        
        if let rating = service.rating {
            ratingLabel.text = String(format: "%.1f", rating)
            ratingView.isHidden = false
        } else {
            ratingView.isHidden = true
        }
        
        if let imageURLString = service.imageURL, let url = URL(string: imageURLString) {
            // Using regular URLSession instead of image libraries (e.g., Kingfisher, SDWebImage)
            print("📱 ServiceCell: Loading image from \(imageURLString)")
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("📱 ServiceCell: Image loading error: \(error.localizedDescription)")
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    print("📱 ServiceCell: Image loaded successfully")
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}

class ReservationCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let serviceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(serviceLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(addressLabel)
        containerView.addSubview(statusView)
        
        statusView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            serviceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            serviceLabel.trailingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: serviceLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addressLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusView.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor)
        ])
    }
    
    func configure(with reservation: Reservation) {
        serviceLabel.text = reservation.service?.name ?? "Unknown Service"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = dateFormatter.string(from: reservation.reservationDate)
        
        addressLabel.text = reservation.address.street
        
        statusLabel.text = reservation.status.displayName
        statusView.backgroundColor = reservation.status.color
    }
}

// MARK: - Extensions

// formattedPrice() 확장 메서드는 Utils/Helpers/Formatter.swift 또는 다른 파일에 정의되어 있으므로 여기서는 제거