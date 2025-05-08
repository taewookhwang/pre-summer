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
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
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
        
        contentView.addSubview(searchBar)
        contentView.addSubview(categoriesLabel)
        contentView.addSubview(categoriesCollectionView)
        contentView.addSubview(featuredServicesLabel)
        contentView.addSubview(servicesCollectionView)
        contentView.addSubview(recentReservationsLabel)
        contentView.addSubview(reservationsTableView)
        
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
        
        // Content view
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoriesLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 8),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            featuredServicesLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 24),
            featuredServicesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            servicesCollectionView.topAnchor.constraint(equalTo: featuredServicesLabel.bottomAnchor, constant: 8),
            servicesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            servicesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            servicesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
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
        
        viewModel.categoriesDidLoad = { [weak self] in
            self?.categoriesCollectionView.reloadData()
        }
        
        viewModel.errorDidOccur = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
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
            
        case .loaded:
            loadingIndicator.stopAnimating()
            errorView.isHidden = true
            scrollView.isHidden = false
            updateEmptyStateView()
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = true
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
            return viewModel.categories.count
        } else {
            return viewModel.featuredServices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = viewModel.categories[indexPath.item]
            cell.configure(with: category)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            let service = viewModel.featuredServices[indexPath.item]
            cell.configure(with: service)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            let category = viewModel.categories[indexPath.item]
            let selectedCategory = viewModel.selectCategory(category)
            // Navigate to search screen when category is selected
            coordinator?.showSearch()
        } else {
            if let service = viewModel.requestServiceDetails(at: indexPath.item) {
                // Navigate to service request screen when service is selected
                coordinator?.showServiceRequest()
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
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
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
        
        addressLabel.text = reservation.address
        
        statusLabel.text = reservation.status.displayName
        statusView.backgroundColor = reservation.status.color
    }
}

// MARK: - Extensions

extension Double {
    func formattedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}