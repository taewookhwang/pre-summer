import UIKit

class JobListVC: UIViewController {
    // MARK: - Properties
    
    var viewModel: JobViewModel!
    weak var coordinator: TechnicianCoordinator?
    
    // UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JobCell.self, forCellReuseIdentifier: "JobCell")
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Current Jobs", "Completed Jobs"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var jobErrorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .white
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.spacing = 16
        
        let errorImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.tintColor = .systemRed
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = "Oops! Something went wrong"
        titleLabel.textAlignment = .center
        
        self.errorMessageLabel = UILabel()
        self.errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorMessageLabel.font = UIFont.systemFont(ofSize: 14)
        self.errorMessageLabel.textColor = .darkGray
        self.errorMessageLabel.numberOfLines = 0
        self.errorMessageLabel.textAlignment = .center
        
        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            errorImageView.widthAnchor.constraint(equalToConstant: 80),
            errorImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        containerStack.addArrangedSubview(errorImageView)
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(self.errorMessageLabel)
        containerStack.addArrangedSubview(retryButton)
        
        view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()
    
    private var errorMessageLabel: UILabel!
    
    private lazy var emptyJobsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .white
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.spacing = 16
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no_jobs") ?? UIImage(systemName: "tray")
        imageView.tintColor = .systemGray3
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = "No Jobs"
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        messageLabel.text = "You don't have any jobs at the moment"
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        containerStack.addArrangedSubview(imageView)
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(messageLabel)
        
        view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
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
        // Refresh data when screen appears (job status update)
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Jobs"
        
        // Navigation setup
        setupNavigationBar()
        
        // Add views
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        view.addSubview(loadingIndicator)
        view.addSubview(jobErrorView)
        view.addSubview(emptyJobsView)
        
        // Constraints setup
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Profile button
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        
        // Schedule button
        let scheduleButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(scheduleButtonTapped)
        )
        
        // Earnings button
        let earningsButton = UIBarButtonItem(
            image: UIImage(systemName: "dollarsign.circle"),
            style: .plain,
            target: self,
            action: #selector(earningsButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [profileButton, scheduleButton, earningsButton]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            jobErrorView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            jobErrorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            jobErrorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            jobErrorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyJobsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 70),
            emptyJobsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyJobsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyJobsView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.jobsDidLoad = { [weak self] in
            self?.tableView.reloadData()
            self?.updateEmptyStateView()
        }
        
        viewModel.errorDidOccur = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    // MARK: - Data
    
    private func loadData() {
        let showCompletedJobs = segmentedControl.selectedSegmentIndex == 1
        viewModel.loadJobs(showCompleted: showCompletedJobs)
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        switch viewModel.state {
        case .idle, .loading:
            loadingIndicator.startAnimating()
            jobErrorView.isHidden = true
            tableView.isHidden = true
            emptyJobsView.isHidden = true
            
        case .loaded:
            loadingIndicator.stopAnimating()
            jobErrorView.isHidden = true
            tableView.isHidden = false
            updateEmptyStateView()
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            jobErrorView.isHidden = false
            tableView.isHidden = true
            emptyJobsView.isHidden = true
            errorMessageLabel.text = message
        }
    }
    
    private func updateEmptyStateView() {
        if viewModel.jobs.isEmpty {
            emptyJobsView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyJobsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func retryButtonTapped() {
        loadData()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        loadData()
    }
    
    @objc private func profileButtonTapped() {
        coordinator?.showProfile()
    }
    
    @objc private func scheduleButtonTapped() {
        coordinator?.showSchedule()
    }
    
    @objc private func earningsButtonTapped() {
        coordinator?.showEarnings()
    }
}

// MARK: - UITableViewDelegate & DataSource

extension JobListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        let job = viewModel.jobs[indexPath.row]
        cell.configure(with: job)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let job = viewModel.jobs[indexPath.row]
        coordinator?.showJobDetail(job: job)
    }
}

// MARK: - JobCell

class JobCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
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
        label.numberOfLines = 2
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
    
    private let clientLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)
        button.tintColor = .darkGray
        return button
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
        containerView.addSubview(clientLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(chatButton)
        
        statusView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
            
            clientLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            clientLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            clientLabel.trailingAnchor.constraint(equalTo: chatButton.leadingAnchor, constant: -8),
            
            statusView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusView.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 120),
            actionButton.heightAnchor.constraint(equalToConstant: 32),
            actionButton.topAnchor.constraint(equalTo: clientLabel.bottomAnchor, constant: 12),
            
            chatButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chatButton.centerYAnchor.constraint(equalTo: clientLabel.centerYAnchor),
            chatButton.widthAnchor.constraint(equalToConstant: 32),
            chatButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func chatButtonTapped() {
        // Chat button action will be handled by the view controller
    }
    
    @objc private func actionButtonTapped() {
        // Action button based on job status will be handled by the view controller
    }
    
    // Update action button based on job status
    private func updateActionButton(for status: JobStatus) {
        switch status {
        case .assigned:
            actionButton.setTitle("Accept", for: .normal)
            actionButton.backgroundColor = .systemGreen
            actionButton.isHidden = false
        case .accepted:
            actionButton.setTitle("On My Way", for: .normal)
            actionButton.backgroundColor = .systemBlue
            actionButton.isHidden = false
        case .onWay:
            actionButton.setTitle("Arrived", for: .normal)
            actionButton.backgroundColor = .systemIndigo
            actionButton.isHidden = false
        case .arrived:
            actionButton.setTitle("Start Job", for: .normal)
            actionButton.backgroundColor = .systemPurple
            actionButton.isHidden = false
        case .inProgress:
            actionButton.setTitle("Complete", for: .normal)
            actionButton.backgroundColor = .systemGreen
            actionButton.isHidden = false
        case .completed, .cancelled:
            actionButton.isHidden = true
        }
    }
    
    func configure(with job: Job) {
        serviceLabel.text = job.reservation?.service?.name ?? "Unknown Service"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = job.reservation?.dateTime {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = "No date"
        }
        
        addressLabel.text = job.reservation?.address ?? "No address"
        
        statusLabel.text = job.status.displayName
        statusView.backgroundColor = job.status.color
        
        if let userId = job.reservation?.userId {
            clientLabel.text = "Client: ID #\(userId)"
        } else {
            clientLabel.text = "Client: Unknown"
        }
        
        updateActionButton(for: job.status)
    }
}