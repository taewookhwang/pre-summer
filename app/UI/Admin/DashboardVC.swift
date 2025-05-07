import UIKit

class DashboardVC: UIViewController {
    // ViewModel
    var viewModel: DashboardViewModel!
    weak var coordinator: AdminCoordinator?
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 상단 카드 컨테이너
    private let dateRangeView = UIView()
    private let dateRangeLabel = UILabel()
    private let dateRangeButton = UIButton(type: .system)
    
    // 통계 카드
    private let statsContainerView = UIView()
    private let statsStackView = UIStackView()
    
    // 차트 컨테이너
    private let chartsContainerView = UIView()
    private let revenueChartView = UIView()
    private let userGrowthChartView = UIView()
    private let serviceDistributionChartView = UIView()
    
    // 테이블 컨테이너
    private let tablesContainerView = UIView()
    private let recentReservationsView = UIView()
    private let recentReviewsView = UIView()
    
    // 로딩 인디케이터
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // 오류 표시 뷰
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        // 대시보드 데이터 로드
        viewModel.loadDashboardData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "관리자 대시보드"
        
        // 새로고침 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshDashboard)
        )
        
        // 스크롤 뷰 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 콘텐츠 뷰 설정
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 날짜 범위 뷰 설정
        setupDateRangeView()
        
        // 통계 카드 설정
        setupStatsView()
        
        // 차트 컨테이너 설정
        setupChartsContainer()
        
        // 테이블 컨테이너 설정
        setupTablesContainer()
        
        // 로딩 인디케이터 설정
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // 오류 뷰 설정
        setupErrorView()
        
        // 레이아웃 제약 조건
        NSLayoutConstraint.activate([
            // 스크롤 뷰
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // 콘텐츠 뷰
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 날짜 범위 뷰
            dateRangeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dateRangeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateRangeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 통계 카드 컨테이너
            statsContainerView.topAnchor.constraint(equalTo: dateRangeView.bottomAnchor, constant: 16),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 차트 컨테이너
            chartsContainerView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 16),
            chartsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 테이블 컨테이너
            tablesContainerView.topAnchor.constraint(equalTo: chartsContainerView.bottomAnchor, constant: 16),
            tablesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tablesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tablesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 오류 뷰
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            errorView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupDateRangeView() {
        dateRangeView.translatesAutoresizingMaskIntoConstraints = false
        dateRangeView.backgroundColor = .systemBackground
        dateRangeView.layer.cornerRadius = 8
        dateRangeView.layer.shadowColor = UIColor.black.cgColor
        dateRangeView.layer.shadowOffset = CGSize(width: 0, height: 1)
        dateRangeView.layer.shadowOpacity = 0.1
        dateRangeView.layer.shadowRadius = 3
        contentView.addSubview(dateRangeView)
        
        // 날짜 범위 레이블
        dateRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateRangeLabel.font = UIFont.systemFont(ofSize: 16)
        dateRangeLabel.textColor = .label
        dateRangeView.addSubview(dateRangeLabel)
        
        // 날짜 범위 선택 버튼
        dateRangeButton.translatesAutoresizingMaskIntoConstraints = false
        dateRangeButton.setTitle("날짜 범위 변경", for: .normal)
        dateRangeButton.addTarget(self, action: #selector(showDateRangePicker), for: .touchUpInside)
        dateRangeView.addSubview(dateRangeButton)
        
        NSLayoutConstraint.activate([
            dateRangeLabel.topAnchor.constraint(equalTo: dateRangeView.topAnchor, constant: 12),
            dateRangeLabel.leadingAnchor.constraint(equalTo: dateRangeView.leadingAnchor, constant: 12),
            dateRangeLabel.bottomAnchor.constraint(equalTo: dateRangeView.bottomAnchor, constant: -12),
            
            dateRangeButton.centerYAnchor.constraint(equalTo: dateRangeLabel.centerYAnchor),
            dateRangeButton.trailingAnchor.constraint(equalTo: dateRangeView.trailingAnchor, constant: -12),
            dateRangeButton.leadingAnchor.constraint(greaterThanOrEqualTo: dateRangeLabel.trailingAnchor, constant: 8)
        ])
    }
    
    private func setupStatsView() {
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.backgroundColor = .systemBackground
        statsContainerView.layer.cornerRadius = 8
        statsContainerView.layer.shadowColor = UIColor.black.cgColor
        statsContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        statsContainerView.layer.shadowOpacity = 0.1
        statsContainerView.layer.shadowRadius = 3
        contentView.addSubview(statsContainerView)
        
        // 통계 스택 뷰
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .vertical
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 16
        statsContainerView.addSubview(statsStackView)
        
        // 통계 행 (2개의 행)
        let row1 = createStatRow()
        let row2 = createStatRow()
        let row3 = createStatRow()
        
        statsStackView.addArrangedSubview(row1)
        statsStackView.addArrangedSubview(row2)
        statsStackView.addArrangedSubview(row3)
        
        // 통계 항목 (각 행당 2개씩, 총 6개)
        addStatItem(to: row1, title: "총 수익", valueTag: 101, iconName: "won.circle.fill")
        addStatItem(to: row1, title: "신규 사용자", valueTag: 102, iconName: "person.crop.circle.badge.plus")
        
        addStatItem(to: row2, title: "활성 예약", valueTag: 103, iconName: "calendar.badge.clock")
        addStatItem(to: row2, title: "완료된 서비스", valueTag: 104, iconName: "checkmark.circle.fill")
        
        addStatItem(to: row3, title: "활성 기술자", valueTag: 105, iconName: "person.crop.circle.fill")
        addStatItem(to: row3, title: "평균 평점", valueTag: 106, iconName: "star.fill")
        
        NSLayoutConstraint.activate([
            statsStackView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createStatRow() -> UIStackView {
        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 16
        return row
    }
    
    private func addStatItem(to row: UIStackView, title: String, valueTag: Int, iconName: String) {
        let statView = UIView()
        statView.translatesAutoresizingMaskIntoConstraints = false
        statView.backgroundColor = .secondarySystemBackground
        statView.layer.cornerRadius = 8
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 22)
        valueLabel.textColor = .label
        valueLabel.tag = valueTag
        
        statView.addSubview(iconView)
        statView.addSubview(titleLabel)
        statView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            statView.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.topAnchor.constraint(equalTo: statView.topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: statView.leadingAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: statView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: statView.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: statView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: statView.trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: statView.bottomAnchor, constant: -12)
        ])
        
        row.addArrangedSubview(statView)
    }
    
    private func setupChartsContainer() {
        chartsContainerView.translatesAutoresizingMaskIntoConstraints = false
        chartsContainerView.backgroundColor = .systemBackground
        chartsContainerView.layer.cornerRadius = 8
        chartsContainerView.layer.shadowColor = UIColor.black.cgColor
        chartsContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        chartsContainerView.layer.shadowOpacity = 0.1
        chartsContainerView.layer.shadowRadius = 3
        contentView.addSubview(chartsContainerView)
        
        // 차트 스택 뷰
        let chartsStackView = UIStackView()
        chartsStackView.translatesAutoresizingMaskIntoConstraints = false
        chartsStackView.axis = .vertical
        chartsStackView.spacing = 16
        chartsStackView.distribution = .fill
        chartsContainerView.addSubview(chartsStackView)
        
        // 수익 차트 뷰
        revenueChartView.translatesAutoresizingMaskIntoConstraints = false
        revenueChartView.backgroundColor = .secondarySystemBackground
        revenueChartView.layer.cornerRadius = 8
        
        let revenueChartLabel = UILabel()
        revenueChartLabel.translatesAutoresizingMaskIntoConstraints = false
        revenueChartLabel.text = "일별 수익"
        revenueChartLabel.font = UIFont.boldSystemFont(ofSize: 16)
        revenueChartView.addSubview(revenueChartLabel)
        
        let revenueChartPlaceholder = UILabel()
        revenueChartPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        revenueChartPlaceholder.text = "차트 영역"
        revenueChartPlaceholder.textAlignment = .center
        revenueChartPlaceholder.textColor = .tertiaryLabel
        revenueChartView.addSubview(revenueChartPlaceholder)
        
        NSLayoutConstraint.activate([
            revenueChartLabel.topAnchor.constraint(equalTo: revenueChartView.topAnchor, constant: 12),
            revenueChartLabel.leadingAnchor.constraint(equalTo: revenueChartView.leadingAnchor, constant: 12),
            revenueChartLabel.trailingAnchor.constraint(equalTo: revenueChartView.trailingAnchor, constant: -12),
            
            revenueChartPlaceholder.topAnchor.constraint(equalTo: revenueChartLabel.bottomAnchor, constant: 8),
            revenueChartPlaceholder.leadingAnchor.constraint(equalTo: revenueChartView.leadingAnchor, constant: 12),
            revenueChartPlaceholder.trailingAnchor.constraint(equalTo: revenueChartView.trailingAnchor, constant: -12),
            revenueChartPlaceholder.bottomAnchor.constraint(equalTo: revenueChartView.bottomAnchor, constant: -12),
            revenueChartPlaceholder.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 사용자 증가 차트 뷰
        userGrowthChartView.translatesAutoresizingMaskIntoConstraints = false
        userGrowthChartView.backgroundColor = .secondarySystemBackground
        userGrowthChartView.layer.cornerRadius = 8
        
        let userGrowthChartLabel = UILabel()
        userGrowthChartLabel.translatesAutoresizingMaskIntoConstraints = false
        userGrowthChartLabel.text = "사용자 증가"
        userGrowthChartLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userGrowthChartView.addSubview(userGrowthChartLabel)
        
        let userGrowthChartPlaceholder = UILabel()
        userGrowthChartPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        userGrowthChartPlaceholder.text = "차트 영역"
        userGrowthChartPlaceholder.textAlignment = .center
        userGrowthChartPlaceholder.textColor = .tertiaryLabel
        userGrowthChartView.addSubview(userGrowthChartPlaceholder)
        
        NSLayoutConstraint.activate([
            userGrowthChartLabel.topAnchor.constraint(equalTo: userGrowthChartView.topAnchor, constant: 12),
            userGrowthChartLabel.leadingAnchor.constraint(equalTo: userGrowthChartView.leadingAnchor, constant: 12),
            userGrowthChartLabel.trailingAnchor.constraint(equalTo: userGrowthChartView.trailingAnchor, constant: -12),
            
            userGrowthChartPlaceholder.topAnchor.constraint(equalTo: userGrowthChartLabel.bottomAnchor, constant: 8),
            userGrowthChartPlaceholder.leadingAnchor.constraint(equalTo: userGrowthChartView.leadingAnchor, constant: 12),
            userGrowthChartPlaceholder.trailingAnchor.constraint(equalTo: userGrowthChartView.trailingAnchor, constant: -12),
            userGrowthChartPlaceholder.bottomAnchor.constraint(equalTo: userGrowthChartView.bottomAnchor, constant: -12),
            userGrowthChartPlaceholder.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 서비스 분포 차트 뷰
        serviceDistributionChartView.translatesAutoresizingMaskIntoConstraints = false
        serviceDistributionChartView.backgroundColor = .secondarySystemBackground
        serviceDistributionChartView.layer.cornerRadius = 8
        
        let serviceDistributionChartLabel = UILabel()
        serviceDistributionChartLabel.translatesAutoresizingMaskIntoConstraints = false
        serviceDistributionChartLabel.text = "서비스 분포"
        serviceDistributionChartLabel.font = UIFont.boldSystemFont(ofSize: 16)
        serviceDistributionChartView.addSubview(serviceDistributionChartLabel)
        
        let serviceDistributionChartPlaceholder = UILabel()
        serviceDistributionChartPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        serviceDistributionChartPlaceholder.text = "차트 영역"
        serviceDistributionChartPlaceholder.textAlignment = .center
        serviceDistributionChartPlaceholder.textColor = .tertiaryLabel
        serviceDistributionChartView.addSubview(serviceDistributionChartPlaceholder)
        
        NSLayoutConstraint.activate([
            serviceDistributionChartLabel.topAnchor.constraint(equalTo: serviceDistributionChartView.topAnchor, constant: 12),
            serviceDistributionChartLabel.leadingAnchor.constraint(equalTo: serviceDistributionChartView.leadingAnchor, constant: 12),
            serviceDistributionChartLabel.trailingAnchor.constraint(equalTo: serviceDistributionChartView.trailingAnchor, constant: -12),
            
            serviceDistributionChartPlaceholder.topAnchor.constraint(equalTo: serviceDistributionChartLabel.bottomAnchor, constant: 8),
            serviceDistributionChartPlaceholder.leadingAnchor.constraint(equalTo: serviceDistributionChartView.leadingAnchor, constant: 12),
            serviceDistributionChartPlaceholder.trailingAnchor.constraint(equalTo: serviceDistributionChartView.trailingAnchor, constant: -12),
            serviceDistributionChartPlaceholder.bottomAnchor.constraint(equalTo: serviceDistributionChartView.bottomAnchor, constant: -12),
            serviceDistributionChartPlaceholder.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 차트 스택 뷰에 추가
        chartsStackView.addArrangedSubview(revenueChartView)
        chartsStackView.addArrangedSubview(userGrowthChartView)
        chartsStackView.addArrangedSubview(serviceDistributionChartView)
        
        NSLayoutConstraint.activate([
            chartsStackView.topAnchor.constraint(equalTo: chartsContainerView.topAnchor, constant: 16),
            chartsStackView.leadingAnchor.constraint(equalTo: chartsContainerView.leadingAnchor, constant: 16),
            chartsStackView.trailingAnchor.constraint(equalTo: chartsContainerView.trailingAnchor, constant: -16),
            chartsStackView.bottomAnchor.constraint(equalTo: chartsContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTablesContainer() {
        tablesContainerView.translatesAutoresizingMaskIntoConstraints = false
        tablesContainerView.backgroundColor = .systemBackground
        tablesContainerView.layer.cornerRadius = 8
        tablesContainerView.layer.shadowColor = UIColor.black.cgColor
        tablesContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        tablesContainerView.layer.shadowOpacity = 0.1
        tablesContainerView.layer.shadowRadius = 3
        contentView.addSubview(tablesContainerView)
        
        // 테이블 스택 뷰
        let tablesStackView = UIStackView()
        tablesStackView.translatesAutoresizingMaskIntoConstraints = false
        tablesStackView.axis = .vertical
        tablesStackView.spacing = 16
        tablesStackView.distribution = .fill
        tablesContainerView.addSubview(tablesStackView)
        
        // 최근 예약 테이블 뷰
        recentReservationsView.translatesAutoresizingMaskIntoConstraints = false
        recentReservationsView.backgroundColor = .secondarySystemBackground
        recentReservationsView.layer.cornerRadius = 8
        
        let recentReservationsLabel = UILabel()
        recentReservationsLabel.translatesAutoresizingMaskIntoConstraints = false
        recentReservationsLabel.text = "최근 예약"
        recentReservationsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        recentReservationsView.addSubview(recentReservationsLabel)
        
        let recentReservationsPlaceholder = UILabel()
        recentReservationsPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        recentReservationsPlaceholder.text = "테이블 영역"
        recentReservationsPlaceholder.textAlignment = .center
        recentReservationsPlaceholder.textColor = .tertiaryLabel
        recentReservationsView.addSubview(recentReservationsPlaceholder)
        
        NSLayoutConstraint.activate([
            recentReservationsLabel.topAnchor.constraint(equalTo: recentReservationsView.topAnchor, constant: 12),
            recentReservationsLabel.leadingAnchor.constraint(equalTo: recentReservationsView.leadingAnchor, constant: 12),
            recentReservationsLabel.trailingAnchor.constraint(equalTo: recentReservationsView.trailingAnchor, constant: -12),
            
            recentReservationsPlaceholder.topAnchor.constraint(equalTo: recentReservationsLabel.bottomAnchor, constant: 8),
            recentReservationsPlaceholder.leadingAnchor.constraint(equalTo: recentReservationsView.leadingAnchor, constant: 12),
            recentReservationsPlaceholder.trailingAnchor.constraint(equalTo: recentReservationsView.trailingAnchor, constant: -12),
            recentReservationsPlaceholder.bottomAnchor.constraint(equalTo: recentReservationsView.bottomAnchor, constant: -12),
            recentReservationsPlaceholder.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 최근 리뷰 테이블 뷰
        recentReviewsView.translatesAutoresizingMaskIntoConstraints = false
        recentReviewsView.backgroundColor = .secondarySystemBackground
        recentReviewsView.layer.cornerRadius = 8
        
        let recentReviewsLabel = UILabel()
        recentReviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        recentReviewsLabel.text = "최근 리뷰"
        recentReviewsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        recentReviewsView.addSubview(recentReviewsLabel)
        
        let recentReviewsPlaceholder = UILabel()
        recentReviewsPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        recentReviewsPlaceholder.text = "테이블 영역"
        recentReviewsPlaceholder.textAlignment = .center
        recentReviewsPlaceholder.textColor = .tertiaryLabel
        recentReviewsView.addSubview(recentReviewsPlaceholder)
        
        NSLayoutConstraint.activate([
            recentReviewsLabel.topAnchor.constraint(equalTo: recentReviewsView.topAnchor, constant: 12),
            recentReviewsLabel.leadingAnchor.constraint(equalTo: recentReviewsView.leadingAnchor, constant: 12),
            recentReviewsLabel.trailingAnchor.constraint(equalTo: recentReviewsView.trailingAnchor, constant: -12),
            
            recentReviewsPlaceholder.topAnchor.constraint(equalTo: recentReviewsLabel.bottomAnchor, constant: 8),
            recentReviewsPlaceholder.leadingAnchor.constraint(equalTo: recentReviewsView.leadingAnchor, constant: 12),
            recentReviewsPlaceholder.trailingAnchor.constraint(equalTo: recentReviewsView.trailingAnchor, constant: -12),
            recentReviewsPlaceholder.bottomAnchor.constraint(equalTo: recentReviewsView.bottomAnchor, constant: -12),
            recentReviewsPlaceholder.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 테이블 스택 뷰에 추가
        tablesStackView.addArrangedSubview(recentReservationsView)
        tablesStackView.addArrangedSubview(recentReviewsView)
        
        NSLayoutConstraint.activate([
            tablesStackView.topAnchor.constraint(equalTo: tablesContainerView.topAnchor, constant: 16),
            tablesStackView.leadingAnchor.constraint(equalTo: tablesContainerView.leadingAnchor, constant: 16),
            tablesStackView.trailingAnchor.constraint(equalTo: tablesContainerView.trailingAnchor, constant: -16),
            tablesStackView.bottomAnchor.constraint(equalTo: tablesContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupErrorView() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.backgroundColor = .systemBackground
        errorView.layer.cornerRadius = 8
        errorView.layer.shadowColor = UIColor.black.cgColor
        errorView.layer.shadowOffset = CGSize(width: 0, height: 1)
        errorView.layer.shadowOpacity = 0.1
        errorView.layer.shadowRadius = 3
        errorView.isHidden = true
        view.addSubview(errorView)
        
        // 오류 아이콘
        let errorIcon = UIImageView()
        errorIcon.translatesAutoresizingMaskIntoConstraints = false
        errorIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        errorIcon.tintColor = .systemRed
        errorIcon.contentMode = .scaleAspectFit
        errorView.addSubview(errorIcon)
        
        // 오류 레이블
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont.systemFont(ofSize: 16)
        errorLabel.textColor = .label
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorView.addSubview(errorLabel)
        
        // 재시도 버튼
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("재시도", for: .normal)
        retryButton.addTarget(self, action: #selector(refreshDashboard), for: .touchUpInside)
        errorView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            errorIcon.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 16),
            errorIcon.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorIcon.widthAnchor.constraint(equalToConstant: 32),
            errorIcon.heightAnchor.constraint(equalToConstant: 32),
            
            errorLabel.topAnchor.constraint(equalTo: errorIcon.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        // 뷰 상태 변경 감지
        viewModel.onViewStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .idle:
                self.loadingIndicator.stopAnimating()
                self.scrollView.isHidden = true
                self.errorView.isHidden = true
                
            case .loading:
                self.loadingIndicator.startAnimating()
                self.scrollView.isHidden = true
                self.errorView.isHidden = true
                
            case .loaded:
                self.loadingIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.errorView.isHidden = true
                
            case .error(let message):
                self.loadingIndicator.stopAnimating()
                self.scrollView.isHidden = true
                self.errorView.isHidden = false
                self.errorLabel.text = message
            }
        }
        
        // 날짜 범위 변경 감지
        viewModel.onDateRangeChanged = { [weak self] dateRange in
            guard let self = self else { return }
            
            self.dateRangeLabel.text = self.viewModel.getDateRangeText()
        }
        
        // 대시보드 데이터 업데이트 감지
        viewModel.onDashboardUpdated = { [weak self] dashboardData in
            guard let self = self else { return }
            
            // 통계 데이터 업데이트
            self.updateStatistics()
            
            // 차트 업데이트 (실제 구현에서는 차트 라이브러리 사용)
            // 테이블 업데이트 (실제 구현에서는 테이블 뷰 사용)
        }
        
        // 오류 감지
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            
            // 이미 ViewState를 통해 오류 표시 중이므로 추가 처리 불필요
        }
    }
    
    private func updateStatistics() {
        // 통계 값 업데이트
        if let totalRevenueLabel = view.viewWithTag(101) as? UILabel {
            totalRevenueLabel.text = viewModel.getTotalRevenueText()
        }
        
        if let newUsersLabel = view.viewWithTag(102) as? UILabel {
            newUsersLabel.text = viewModel.getNewUsersText()
        }
        
        if let activeReservationsLabel = view.viewWithTag(103) as? UILabel {
            activeReservationsLabel.text = viewModel.getActiveReservationsText()
        }
        
        if let completedServicesLabel = view.viewWithTag(104) as? UILabel {
            completedServicesLabel.text = viewModel.getCompletedServicesText()
        }
        
        if let totalTechniciansLabel = view.viewWithTag(105) as? UILabel {
            totalTechniciansLabel.text = viewModel.getTotalTechniciansText()
        }
        
        if let averageRatingLabel = view.viewWithTag(106) as? UILabel {
            averageRatingLabel.text = viewModel.getAverageRatingText()
        }
    }
    
    // MARK: - 액션 메서드
    
    @objc private func refreshDashboard() {
        viewModel.loadDashboardData()
    }
    
    @objc private func showDateRangePicker() {
        let alertController = UIAlertController(title: "날짜 범위 선택", message: nil, preferredStyle: .actionSheet)
        
        // 날짜 범위 옵션 추가
        let today = UIAlertAction(title: "오늘", style: .default) { [weak self] _ in
            self?.applyDateRange(.today)
        }
        
        let thisWeek = UIAlertAction(title: "이번 주", style: .default) { [weak self] _ in
            self?.applyDateRange(.thisWeek)
        }
        
        let thisMonth = UIAlertAction(title: "이번 달", style: .default) { [weak self] _ in
            self?.applyDateRange(.thisMonth)
        }
        
        let lastMonth = UIAlertAction(title: "지난 달", style: .default) { [weak self] _ in
            self?.applyDateRange(.lastMonth)
        }
        
        let lastQuarter = UIAlertAction(title: "지난 분기", style: .default) { [weak self] _ in
            self?.applyDateRange(.lastQuarter)
        }
        
        let thisYear = UIAlertAction(title: "올해", style: .default) { [weak self] _ in
            self?.applyDateRange(.thisYear)
        }
        
        let lastYear = UIAlertAction(title: "작년", style: .default) { [weak self] _ in
            self?.applyDateRange(.lastYear)
        }
        
        let custom = UIAlertAction(title: "사용자 지정", style: .default) { [weak self] _ in
            self?.showCustomDatePicker()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(today)
        alertController.addAction(thisWeek)
        alertController.addAction(thisMonth)
        alertController.addAction(lastMonth)
        alertController.addAction(lastQuarter)
        alertController.addAction(thisYear)
        alertController.addAction(lastYear)
        alertController.addAction(custom)
        alertController.addAction(cancel)
        
        // iPad 호환을 위한 popover 설정
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = dateRangeButton
            popoverController.sourceRect = dateRangeButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func applyDateRange(_ rangeType: DateRangeType) {
        let dateRange = viewModel.calculateDateRange(for: rangeType)
        viewModel.updateDateRange(startDate: dateRange.startDate, endDate: dateRange.endDate)
    }
    
    private func showCustomDatePicker() {
        // 실제 구현에서는 날짜 선택 UI 표시
        // 여기서는 간단한 알림으로 대체
        
        let alert = UIAlertController(title: "알림", message: "날짜 선택 기능은 개발 중입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}