import UIKit

class JobStatusUpdateVC: UIViewController {
    // MARK: - Properties
    
    var viewModel: JobStatusUpdateViewModel!
    weak var coordinator: TechnicianCoordinator?
    
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var serviceInfoCard: UIView = {
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
    
    private lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var statusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var statusValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var customerInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var statusButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Notes"
        return label
    }()
    
    private lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 8
        textView.isEditable = true
        return textView
    }()
    
    private lazy var saveNotesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Notes", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveNotesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Contact Customer", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Upload Photos", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Job Status Update"
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(serviceInfoCard)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(statusButtonsStackView)
        stackView.addArrangedSubview(notesLabel)
        stackView.addArrangedSubview(notesTextView)
        stackView.addArrangedSubview(saveNotesButton)
        stackView.addArrangedSubview(chatButton)
        stackView.addArrangedSubview(photoButton)
        
        // Setup service info card
        serviceInfoCard.addSubview(serviceNameLabel)
        serviceInfoCard.addSubview(dateLabel)
        serviceInfoCard.addSubview(addressLabel)
        serviceInfoCard.addSubview(statusView)
        serviceInfoCard.addSubview(customerInfoLabel)
        statusView.addSubview(statusValueLabel)
        
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        setupStatusButtons()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Service info card
            serviceInfoCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            serviceNameLabel.topAnchor.constraint(equalTo: serviceInfoCard.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: serviceInfoCard.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: serviceInfoCard.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: serviceInfoCard.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: serviceInfoCard.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: serviceInfoCard.trailingAnchor, constant: -16),
            
            customerInfoLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            customerInfoLabel.leadingAnchor.constraint(equalTo: serviceInfoCard.leadingAnchor, constant: 16),
            customerInfoLabel.trailingAnchor.constraint(equalTo: serviceInfoCard.trailingAnchor, constant: -16),
            customerInfoLabel.bottomAnchor.constraint(equalTo: serviceInfoCard.bottomAnchor, constant: -16),
            
            statusView.topAnchor.constraint(equalTo: serviceInfoCard.topAnchor, constant: 16),
            statusView.trailingAnchor.constraint(equalTo: serviceInfoCard.trailingAnchor, constant: -16),
            statusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            statusView.heightAnchor.constraint(equalToConstant: 28),
            
            statusValueLabel.topAnchor.constraint(equalTo: statusView.topAnchor),
            statusValueLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
            statusValueLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),
            statusValueLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            
            // Notes text view
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.jobDidUpdate = { [weak self] _ in
            self?.updateUI()
        }
        
        viewModel.errorDidOccur = { [weak self] message in
            self?.showErrorAlert(message: message)
        }
    }
    
    private func setupStatusButtons() {
        // Clear existing buttons
        statusButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add buttons for available status options
        for statusOption in viewModel.availableStatusOptions {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(viewModel.getStatusActionText(for: statusOption), for: .normal)
            button.backgroundColor = statusOption == .cancelled ? .systemRed : statusOption.color
            button.layer.cornerRadius = 8
            button.tag = statusOption.hashValue
            button.addTarget(self, action: #selector(statusButtonTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            statusButtonsStackView.addArrangedSubview(button)
        }
        
        // Hide status buttons if no options available
        statusButtonsStackView.isHidden = viewModel.availableStatusOptions.isEmpty
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        let job = viewModel.job
        
        // Set status label
        statusLabel.text = viewModel.getCurrentStatusDescription()
        
        // Set service info
        serviceNameLabel.text = job.reservation?.service?.name ?? "Service Unavailable"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = job.reservation?.dateTime {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = "Date Unknown"
        }
        
        addressLabel.text = job.reservation?.address ?? "Address Unavailable"
        
        // Customer info (based on userId rather than direct customer object)
        customerInfoLabel.text = "Customer ID: \(job.reservation?.userId ?? 0)"
        
        // Set status info
        statusValueLabel.text = job.status.displayName
        statusView.backgroundColor = job.status.color
        
        // Set request details - using specialInstructions instead of requestDetails
        descriptionLabel.text = job.reservation?.specialInstructions ?? "No special instructions provided."
        
        // Set notes
        notesTextView.text = job.notes ?? ""
        
        // Update status buttons
        setupStatusButtons()
        
        // Show/hide buttons based on job status
        let isCompleted = job.status == .completed || job.status == .cancelled
        saveNotesButton.isHidden = isCompleted
        photoButton.isHidden = !(job.status == .completed)
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
    
    private func showLoadingIndicator(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func statusButtonTapped(_ sender: UIButton) {
        guard let statusIndex = viewModel.availableStatusOptions.firstIndex(where: { $0.hashValue == sender.tag }),
              let newStatus = viewModel.availableStatusOptions[safe: statusIndex] else {
            return
        }
        
        showLoadingIndicator(true)
        
        viewModel.updateStatus(to: newStatus) { [weak self] success in
            DispatchQueue.main.async {
                self?.showLoadingIndicator(false)
                
                if success {
                    // Show success message if needed
                    if newStatus == .completed {
                        self?.showSuccessAlert(message: "Job completed successfully!")
                    } else if newStatus == .cancelled {
                        self?.showSuccessAlert(message: "Job has been cancelled.")
                    }
                }
            }
        }
    }
    
    @objc private func saveNotesButtonTapped() {
        guard let notes = notesTextView.text, !notes.isEmpty else {
            showErrorAlert(message: "Please enter notes.")
            return
        }
        
        showLoadingIndicator(true)
        
        viewModel.updateNotes(notes: notes) { [weak self] success in
            DispatchQueue.main.async {
                self?.showLoadingIndicator(false)
                
                if success {
                    self?.showSuccessAlert(message: "Notes saved successfully.")
                }
            }
        }
    }
    
    @objc private func chatButtonTapped() {
        coordinator?.showChat(for: viewModel.job)
    }
    
    @objc private func photoButtonTapped() {
        coordinator?.showJobPhotoUpload(job: viewModel.job)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}