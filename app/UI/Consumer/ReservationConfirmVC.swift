import UIKit

class ReservationConfirmVC: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: ReservationConfirmViewModel!
    weak var coordinator: ConsumerCoordinator?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "예약 확인"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var reservationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var serviceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var addressTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "서비스 주소"
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var instructionsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "특별 요청사항"
        return label
    }()
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "결제 금액"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .systemBlue
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var paymentMethodsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "결제 방법 선택"
        return label
    }()
    
    private lazy var paymentMethodsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var cardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("신용카드", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.tag = 0
        button.addTarget(self, action: #selector(paymentMethodSelected(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var virtualAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("가상계좌", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.tag = 1
        button.addTarget(self, action: #selector(paymentMethodSelected(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var phoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("휴대폰 결제", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.tag = 2
        button.addTarget(self, action: #selector(paymentMethodSelected(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("결제하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // 선택된 결제 방법
    private var selectedPaymentMethod: String?
    private var selectedPaymentButton: UIButton?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "예약 확인"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(reservationContainer)
        
        reservationContainer.addSubview(serviceNameLabel)
        reservationContainer.addSubview(dateTimeLabel)
        reservationContainer.addSubview(addressTitleLabel)
        reservationContainer.addSubview(addressLabel)
        
        if viewModel.reservation.specialInstructions != nil && !viewModel.reservation.specialInstructions!.isEmpty {
            reservationContainer.addSubview(instructionsTitleLabel)
            reservationContainer.addSubview(instructionsLabel)
        }
        
        contentView.addSubview(priceTitleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(durationLabel)
        
        contentView.addSubview(paymentMethodsLabel)
        contentView.addSubview(paymentMethodsStack)
        
        paymentMethodsStack.addArrangedSubview(cardButton)
        paymentMethodsStack.addArrangedSubview(virtualAccountButton)
        paymentMethodsStack.addArrangedSubview(phoneButton)
        
        view.addSubview(payButton)
        view.addSubview(loadingIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // ScrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Title
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Reservation Info Container
        NSLayoutConstraint.activate([
            reservationContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            reservationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reservationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            serviceNameLabel.topAnchor.constraint(equalTo: reservationContainer.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16),
            
            dateTimeLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 8),
            dateTimeLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
            dateTimeLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16),
            
            addressTitleLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 16),
            addressTitleLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
            addressTitleLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: addressTitleLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16)
        ])
        
        // If special instructions exist
        if viewModel.reservation.specialInstructions != nil && !viewModel.reservation.specialInstructions!.isEmpty {
            NSLayoutConstraint.activate([
                instructionsTitleLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
                instructionsTitleLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
                instructionsTitleLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16),
                
                instructionsLabel.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 8),
                instructionsLabel.leadingAnchor.constraint(equalTo: reservationContainer.leadingAnchor, constant: 16),
                instructionsLabel.trailingAnchor.constraint(equalTo: reservationContainer.trailingAnchor, constant: -16),
                instructionsLabel.bottomAnchor.constraint(equalTo: reservationContainer.bottomAnchor, constant: -16)
            ])
        } else {
            // If no special instructions
            NSLayoutConstraint.activate([
                addressLabel.bottomAnchor.constraint(equalTo: reservationContainer.bottomAnchor, constant: -16)
            ])
        }
        
        // Price
        NSLayoutConstraint.activate([
            priceTitleLabel.topAnchor.constraint(equalTo: reservationContainer.bottomAnchor, constant: 24),
            priceTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            priceLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            durationLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Payment Methods
        NSLayoutConstraint.activate([
            paymentMethodsLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 24),
            paymentMethodsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            paymentMethodsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            paymentMethodsStack.topAnchor.constraint(equalTo: paymentMethodsLabel.bottomAnchor, constant: 16),
            paymentMethodsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            paymentMethodsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            paymentMethodsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            cardButton.heightAnchor.constraint(equalToConstant: 50),
            virtualAccountButton.heightAnchor.constraint(equalToConstant: 50),
            phoneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Pay Button
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Loading Indicator
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.stateDidChange = { [weak self] in
            self?.updateStateUI()
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Update service info
        serviceNameLabel.text = viewModel.serviceName()
        dateTimeLabel.text = viewModel.formattedReservationDate()
        addressLabel.text = viewModel.reservation.address.street
        
        if let specialInstructions = viewModel.reservation.specialInstructions, !specialInstructions.isEmpty {
            instructionsLabel.text = specialInstructions
        }
        
        // Update price and duration
        priceLabel.text = viewModel.servicePrice()
        durationLabel.text = viewModel.serviceDuration()
    }
    
    private func updateStateUI() {
        switch viewModel.state {
        case .idle:
            loadingIndicator.stopAnimating()
            payButton.isEnabled = selectedPaymentMethod != nil
            payButton.alpha = selectedPaymentMethod != nil ? 1.0 : 0.5
            
        case .loading:
            loadingIndicator.startAnimating()
            payButton.isEnabled = false
            payButton.alpha = 0.5
            
        case .success(let paymentURL):
            loadingIndicator.stopAnimating()
            // 결제 웹뷰로 이동
            coordinator?.showPaymentWebView(paymentURL: paymentURL, reservation: viewModel.reservation)
            
        case .error(let message):
            loadingIndicator.stopAnimating()
            payButton.isEnabled = selectedPaymentMethod != nil
            payButton.alpha = selectedPaymentMethod != nil ? 1.0 : 0.5
            showErrorAlert(message: message)
        }
    }
    
    // MARK: - Actions
    
    @objc private func paymentMethodSelected(_ sender: UIButton) {
        // 이전에 선택된 버튼 초기화
        selectedPaymentButton?.backgroundColor = .white
        selectedPaymentButton?.setTitleColor(.black, for: .normal)
        selectedPaymentButton?.layer.borderColor = UIColor.systemGray4.cgColor
        
        // 현재 버튼 활성화
        sender.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        sender.setTitleColor(.systemBlue, for: .normal)
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        
        // 결제 방법 설정
        switch sender.tag {
        case 0:
            selectedPaymentMethod = "card"
        case 1:
            selectedPaymentMethod = "vbank"
        case 2:
            selectedPaymentMethod = "phone"
        default:
            selectedPaymentMethod = nil
        }
        
        // 참조 저장
        selectedPaymentButton = sender
        
        // 결제 버튼 활성화
        payButton.isEnabled = selectedPaymentMethod != nil
        payButton.alpha = selectedPaymentMethod != nil ? 1.0 : 0.5
    }
    
    @objc private func payButtonTapped() {
        guard let paymentMethod = selectedPaymentMethod else {
            showErrorAlert(message: "결제 방법을 선택해주세요.")
            return
        }
        
        viewModel.createPayment(paymentMethod: paymentMethod)
    }
    
    // MARK: - Alert Helpers
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "확인",
            style: .default
        ))
        
        present(alert, animated: true)
    }
}