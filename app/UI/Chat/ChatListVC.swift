import UIKit

class ChatListVC: UIViewController {
    // ViewModel
    private let viewModel = ChatListViewModel()
    weak var coordinator: CoordinatorProtocol?
    
    // UI Components
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(image: nil, title: "채팅 없음", message: "아직 채팅방이 없습니다")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        // 채팅방 목록 로드
        viewModel.loadChatRooms()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "채팅 목록"
        
        // 채팅방 생성 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createNewChatRoom)
        )
        
        // TableView 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatRoomCell")
        tableView.rowHeight = 70
        view.addSubview(tableView)
        
        // 로딩 인디케이터 설정
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // 빈 상태 뷰 설정
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        // 레이아웃 제약조건
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupBindings() {
        // 채팅방 목록 업데이트 감지
        viewModel.onRoomsUpdated = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            self.updateUIState()
        }
        
        // 에러 처리
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
    }
    
    private func updateUIState() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            emptyStateView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            
            if viewModel.chatRooms.isEmpty {
                emptyStateView.isHidden = false
                tableView.isHidden = true
            } else {
                emptyStateView.isHidden = true
                tableView.isHidden = false
            }
        }
    }
    
    @objc private func createNewChatRoom() {
        // 실제 구현에서는 상대방 선택 화면 등을 표시할 수 있음
        // 간단한 구현을 위해 더미 채팅방 생성
        
        viewModel.createNewChatRoom(withUserId: "user_\(Int.random(in: 1000...9999))") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let roomId):
                // 생성된 채팅방으로 이동
                self.navigateToChatRoom(roomId: roomId)
            case .failure(let error):
                let alert = UIAlertController(
                    title: "채팅방 생성 실패",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func navigateToChatRoom(roomId: String) {
        // 코디네이터를 통해 채팅방으로 이동
        // 미구현 상태이므로 간단한 알림만 표시
        
        let alert = UIAlertController(
            title: "채팅방 이동",
            message: "채팅방 ID: \(roomId)로 이동합니다. (미구현)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
        
        // 코디네이터가 구현되면 아래 코드 활성화
        // coordinator?.navigateToChatRoom(roomId: roomId)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath)
        
        if indexPath.row < viewModel.chatRooms.count {
            let roomId = viewModel.chatRooms[indexPath.row]
            let displayName = viewModel.getRoomDisplayName(roomId: roomId)
            
            // 기본 셀 구성
            var configuration = cell.defaultContentConfiguration()
            configuration.text = displayName
            
            // 최근 메시지 표시 (있는 경우)
            if let latestMessage = viewModel.getLatestMessage(forRoomId: roomId) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timeString = timeFormatter.string(from: latestMessage.timestamp)
                
                configuration.secondaryText = "\(latestMessage.content) - \(timeString)"
            } else {
                configuration.secondaryText = "새로운 대화를 시작하세요"
            }
            
            cell.contentConfiguration = configuration
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < viewModel.chatRooms.count {
            let roomId = viewModel.chatRooms[indexPath.row]
            navigateToChatRoom(roomId: roomId)
        }
    }
}