import UIKit

class ScheduleVC: UIViewController {
    // ViewModel
    var viewModel: ScheduleViewModel!
    weak var coordinator: TechnicianCoordinator?
    
    // UI Components
    private let calendarView = UIView()
    private let scheduleTableView = UITableView()
    private let dateLabel = UILabel()
    private let prevDayButton = UIButton(type: .system)
    private let nextDayButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView = UIView()
    
    // Calendar Navigation
    private let weekdayLabels: [UILabel] = (0..<7).map { _ in UILabel() }
    private let dateButtons: [UIButton] = (0..<42).map { _ in UIButton(type: .system) }
    private var selectedDateButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        // 초기 일정 로드
        viewModel.loadSchedule(for: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면 진입 시마다 선택된 날짜 기준으로 일정 다시 로드
        if let date = viewModel.selectedDate {
            viewModel.loadSchedule(for: date)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "일정 관리"
        
        // 네비게이션 바 설정
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshSchedule)
        )
        
        // 캘린더 뷰 설정
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .systemGray6
        calendarView.layer.cornerRadius = 8
        view.addSubview(calendarView)
        
        // 날짜 네비게이션 설정
        setupDateNavigation()
        
        // 테이블 뷰 설정
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "JobCell")
        scheduleTableView.backgroundColor = .white
        scheduleTableView.separatorStyle = .singleLine
        scheduleTableView.rowHeight = UITableView.automaticDimension
        scheduleTableView.estimatedRowHeight = 80
        view.addSubview(scheduleTableView)
        
        // 로딩 인디케이터 설정
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // 빈 상태 뷰 설정
        setupEmptyStateView()
        
        // 레이아웃 제약조건
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 300),
            
            dateLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 16),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            prevDayButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            prevDayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            prevDayButton.widthAnchor.constraint(equalToConstant: 44),
            prevDayButton.heightAnchor.constraint(equalToConstant: 44),
            
            nextDayButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            nextDayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextDayButton.widthAnchor.constraint(equalToConstant: 44),
            nextDayButton.heightAnchor.constraint(equalToConstant: 44),
            
            scheduleTableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: scheduleTableView.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: scheduleTableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: scheduleTableView.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 250),
            emptyStateView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        // 캘린더 UI 설정
        setupCalendarUI()
    }
    
    private func setupDateNavigation() {
        // 날짜 레이블 설정
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.boldSystemFont(ofSize: 18)
        dateLabel.textAlignment = .center
        view.addSubview(dateLabel)
        
        // 이전 날짜 버튼 설정
        prevDayButton.translatesAutoresizingMaskIntoConstraints = false
        prevDayButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevDayButton.tintColor = .systemBlue
        prevDayButton.addTarget(self, action: #selector(goToPreviousDay), for: .touchUpInside)
        view.addSubview(prevDayButton)
        
        // 다음 날짜 버튼 설정
        nextDayButton.translatesAutoresizingMaskIntoConstraints = false
        nextDayButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextDayButton.tintColor = .systemBlue
        nextDayButton.addTarget(self, action: #selector(goToNextDay), for: .touchUpInside)
        view.addSubview(nextDayButton)
    }
    
    private func setupCalendarUI() {
        // 월 헤더 캘린더 설정
        let monthHeader = UIView()
        monthHeader.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(monthHeader)
        
        let monthLabel = UILabel()
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont.boldSystemFont(ofSize: 16)
        monthLabel.textAlignment = .center
        monthHeader.addSubview(monthLabel)
        
        let prevMonthButton = UIButton(type: .system)
        prevMonthButton.translatesAutoresizingMaskIntoConstraints = false
        prevMonthButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevMonthButton.addTarget(self, action: #selector(goToPreviousMonth), for: .touchUpInside)
        monthHeader.addSubview(prevMonthButton)
        
        let nextMonthButton = UIButton(type: .system)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextMonthButton.addTarget(self, action: #selector(goToNextMonth), for: .touchUpInside)
        monthHeader.addSubview(nextMonthButton)
        
        NSLayoutConstraint.activate([
            monthHeader.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 8),
            monthHeader.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            monthHeader.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            monthHeader.heightAnchor.constraint(equalToConstant: 30),
            
            monthLabel.centerXAnchor.constraint(equalTo: monthHeader.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: monthHeader.centerYAnchor),
            
            prevMonthButton.leadingAnchor.constraint(equalTo: monthHeader.leadingAnchor, constant: 16),
            prevMonthButton.centerYAnchor.constraint(equalTo: monthHeader.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: monthHeader.trailingAnchor, constant: -16),
            nextMonthButton.centerYAnchor.constraint(equalTo: monthHeader.centerYAnchor)
        ])
        
        // 요일 헤더 설정
        let weekdayHeader = UIView()
        weekdayHeader.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(weekdayHeader)
        
        // 요일 레이블 설정
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let weekdayStackView = UIStackView()
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.spacing = 0
        weekdayHeader.addSubview(weekdayStackView)
        
        for (index, label) in weekdayLabels.enumerated() {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = weekdays[index]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            
            // 일요일은 빨간색, 토요일은 파란색으로 표시
            if index == 0 {
                label.textColor = .systemRed
            } else if index == 6 {
                label.textColor = .systemBlue
            }
            
            weekdayStackView.addArrangedSubview(label)
        }
        
        NSLayoutConstraint.activate([
            weekdayHeader.topAnchor.constraint(equalTo: monthHeader.bottomAnchor, constant: 8),
            weekdayHeader.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            weekdayHeader.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            weekdayHeader.heightAnchor.constraint(equalToConstant: 20),
            
            weekdayStackView.topAnchor.constraint(equalTo: weekdayHeader.topAnchor),
            weekdayStackView.leadingAnchor.constraint(equalTo: weekdayHeader.leadingAnchor, constant: 8),
            weekdayStackView.trailingAnchor.constraint(equalTo: weekdayHeader.trailingAnchor, constant: -8),
            weekdayStackView.bottomAnchor.constraint(equalTo: weekdayHeader.bottomAnchor)
        ])
        
        // 날짜 그리드 설정
        let dateGrid = UIView()
        dateGrid.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(dateGrid)
        
        // 6행 7열 그리드 생성
        let gridWidth = Int(calendarView.bounds.width - 16)
        let cellWidth = gridWidth / 7
        let cellHeight = 35
        
        for i in 0..<42 {
            let row = i / 7
            let col = i % 7
            
            let button = dateButtons[i]
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = .clear
            button.layer.cornerRadius = CGFloat(cellHeight) / 2
            button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            button.tag = i
            
            dateGrid.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: dateGrid.topAnchor, constant: CGFloat(row * cellHeight)),
                button.leadingAnchor.constraint(equalTo: dateGrid.leadingAnchor, constant: CGFloat(col * cellWidth + 8)),
                button.widthAnchor.constraint(equalToConstant: CGFloat(cellWidth - 4)),
                button.heightAnchor.constraint(equalToConstant: CGFloat(cellHeight))
            ])
        }
        
        NSLayoutConstraint.activate([
            dateGrid.topAnchor.constraint(equalTo: weekdayHeader.bottomAnchor, constant: 8),
            dateGrid.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            dateGrid.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            dateGrid.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -8),
            dateGrid.heightAnchor.constraint(equalToConstant: CGFloat(6 * cellHeight))
        ])
        
        // 현재 캘린더 갱신
        viewModel.updateCurrentMonth()
        updateCalendarUI()
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "calendar.badge.exclamationmark")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        emptyStateView.addSubview(imageView)
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "일정이 없습니다"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .systemGray
        messageLabel.textAlignment = .center
        emptyStateView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // 날짜 선택 콜백
        viewModel.onDateSelected = { [weak self] date in
            guard let self = self else { return }
            
            // 날짜 레이블 업데이트
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일 (E)"
            formatter.locale = Locale(identifier: "ko_KR")
            self.dateLabel.text = formatter.string(from: date)
            
            // 캘린더 UI 업데이트
            self.updateCalendarUI()
        }
        
        // 로딩 상태 콜백
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self = self else { return }
            
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
        
        // 일정 업데이트 콜백
        viewModel.onScheduleUpdated = { [weak self] jobs in
            guard let self = self else { return }
            
            self.scheduleTableView.reloadData()
            
            // 빈 상태 뷰 표시 여부 설정
            self.emptyStateView.isHidden = !jobs.isEmpty
            self.scheduleTableView.isHidden = jobs.isEmpty
        }
        
        // 오류 콜백
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "오류",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
        
        // 월간 날짜 변경 콜백
        viewModel.onMonthChanged = { [weak self] month in
            guard let self = self else { return }
            
            // 월 레이블 업데이트
            let monthLabel = self.calendarView.subviews.first?.subviews.first { $0 is UILabel } as? UILabel
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월"
            formatter.locale = Locale(identifier: "ko_KR")
            monthLabel?.text = formatter.string(from: month)
            
            // 날짜 그리드 업데이트
            self.updateCalendarUI()
        }
    }
    
    private func updateCalendarUI() {
        guard let calendarData = viewModel.getCalendarData() else { return }
        
        for (index, date) in calendarData.enumerated() {
            let button = dateButtons[index]
            
            if let date = date {
                // 날짜 숫자로 설정
                button.setTitle("\(Calendar.current.component(.day, from: date))", for: .normal)
                button.isEnabled = true
                
                // 오늘 날짜 표시
                let isToday = Calendar.current.isDateInToday(date)
                button.layer.borderWidth = isToday ? 1 : 0
                button.layer.borderColor = UIColor.systemBlue.cgColor
                
                // 선택된 날짜 표시
                let isSelected = viewModel.isDateSelected(date)
                button.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.2) : .clear
                
                // 일요일 빨간색, 토요일 파란색으로 표시
                let weekday = Calendar.current.component(.weekday, from: date)
                if weekday == 1 {
                    button.setTitleColor(.systemRed, for: .normal)
                } else if weekday == 7 {
                    button.setTitleColor(.systemBlue, for: .normal)
                } else {
                    button.setTitleColor(.label, for: .normal)
                }
                
                // 일정 있는 날짜 표시
                let hasJob = viewModel.hasJobs(on: date)
                let dotView = button.viewWithTag(1000)
                
                if hasJob && dotView == nil {
                    let dot = UIView()
                    dot.translatesAutoresizingMaskIntoConstraints = false
                    dot.backgroundColor = .systemGreen
                    dot.layer.cornerRadius = 3
                    dot.tag = 1000
                    button.addSubview(dot)
                    
                    NSLayoutConstraint.activate([
                        dot.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                        dot.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -2),
                        dot.widthAnchor.constraint(equalToConstant: 6),
                        dot.heightAnchor.constraint(equalToConstant: 6)
                    ])
                } else if !hasJob && dotView != nil {
                    dotView?.removeFromSuperview()
                }
            } else {
                // 현재 월에 속하지 않는 날짜 비활성화
                button.setTitle("", for: .normal)
                button.isEnabled = false
                button.backgroundColor = .clear
                
                // 점 표시 제거
                button.viewWithTag(1000)?.removeFromSuperview()
            }
        }
    }
    
    // MARK: - 액션 메서드
    
    @objc private func refreshSchedule() {
        if let date = viewModel.selectedDate {
            viewModel.loadSchedule(for: date)
        }
    }
    
    @objc private func goToPreviousDay() {
        viewModel.selectPreviousDay()
    }
    
    @objc private func goToNextDay() {
        viewModel.selectNextDay()
    }
    
    @objc private func goToPreviousMonth() {
        viewModel.selectPreviousMonth()
    }
    
    @objc private func goToNextMonth() {
        viewModel.selectNextMonth()
    }
    
    @objc private func dateButtonTapped(_ sender: UIButton) {
        if let date = viewModel.getDateForButton(at: sender.tag) {
            viewModel.selectDate(date)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)
        
        if indexPath.row < viewModel.jobs.count {
            let job = viewModel.jobs[indexPath.row]
            
            var configuration = cell.defaultContentConfiguration()
            
            // 시작 시간
            let startTimeString = formatTime(job.startTime)
            
            // 예약 정보
            if let reservation = job.reservation {
                configuration.text = "\(startTimeString) - \(reservation.address.street)"
                
                if let service = reservation.service {
                    configuration.secondaryText = "\(service.name) - \(job.status.displayName)"
                } else {
                    configuration.secondaryText = job.status.displayName
                }
            } else {
                configuration.text = "\(startTimeString) - 작업 #\(job.id)"
                configuration.secondaryText = job.status.displayName
            }
            
            // 작업 상태에 따른 스타일 설정
            switch job.status {
            case .completed:
                cell.accessoryType = .checkmark
            case .cancelled:
                cell.accessoryType = .none
                configuration.textProperties.color = .systemGray
                configuration.secondaryTextProperties.color = .systemGray
            default:
                cell.accessoryType = .disclosureIndicator
            }
            
            cell.contentConfiguration = configuration
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < viewModel.jobs.count {
            let job = viewModel.jobs[indexPath.row]
            
            // 코디네이터를 통해 작업 상세 화면으로 이동
            coordinator?.navigateToJobDetail(jobId: job.id)
        }
    }
    
    // 시간 포맷팅 헬퍼 메서드
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "미정" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}