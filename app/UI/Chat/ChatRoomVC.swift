import UIKit

class ChatRoomVC: UIViewController {
    // ViewModel
    private var viewModel: ChatRoomViewModel!
    weak var coordinator: CoordinatorProtocol?
    
    // UI Components
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let typingIndicatorLabel = UILabel()
    
    // Constraints that will need to be updated
    private var messageInputBottomConstraint: NSLayoutConstraint!
    
    // Setting the room ID and initializing the view model
    func configure(with roomId: String) {
        viewModel = ChatRoomViewModel(roomId: roomId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboardObservers()
        
        // Connect to room
        connectToRoom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reconnect if needed
        if !viewModel.isConnected {
            connectToRoom()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Disconnect when leaving
        viewModel.disconnect()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "채팅"
        
        // TableView 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        view.addSubview(tableView)
        
        // 메시지 입력 영역 설정
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.backgroundColor = .systemGray6
        messageInputView.layer.borderWidth = 0.5
        messageInputView.layer.borderColor = UIColor.systemGray4.cgColor
        view.addSubview(messageInputView)
        
        // 메시지 입력 필드 설정
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.placeholder = "메시지를 입력하세요..."
        messageTextField.backgroundColor = .white
        messageTextField.layer.cornerRadius = 18
        messageTextField.layer.borderWidth = 0.5
        messageTextField.layer.borderColor = UIColor.systemGray3.cgColor
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        messageTextField.leftViewMode = .always
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        messageInputView.addSubview(messageTextField)
        
        // 전송 버튼 설정
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("전송", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        messageInputView.addSubview(sendButton)
        
        // 타이핑 인디케이터 라벨 설정
        typingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        typingIndicatorLabel.font = UIFont.systemFont(ofSize: 12)
        typingIndicatorLabel.textColor = .systemGray
        typingIndicatorLabel.text = ""
        messageInputView.addSubview(typingIndicatorLabel)
        
        // 로딩 인디케이터 설정
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        // 레이아웃 제약조건 - 메시지 입력 영역을 화면 하단에 고정
        messageInputBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // 메시지 입력 영역
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBottomConstraint,
            messageInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // 메시지 입력 필드
            messageTextField.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 12),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextField.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 12),
            messageTextField.heightAnchor.constraint(equalToConstant: 36),
            
            // 전송 버튼
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            
            // 타이핑 인디케이터 라벨
            typingIndicatorLabel.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 12),
            typingIndicatorLabel.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 4),
            typingIndicatorLabel.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: -4),
            
            // 테이블뷰 - 메시지 목록
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        // 메시지 목록 업데이트 감지
        viewModel.onMessagesUpdated = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
            // 스크롤을 가장 최근 메시지로 이동
            if !self.viewModel.messages.isEmpty {
                let lastRow = self.viewModel.messages.count - 1
                let indexPath = IndexPath(row: lastRow, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        // 연결 상태 변경 감지
        viewModel.onConnectionStatusChanged = { [weak self] isConnected in
            guard let self = self else { return }
            
            if isConnected {
                // 연결됨 - 상태 표시
                self.title = "채팅 - 연결됨"
            } else {
                // 연결 끊김 - 상태 표시
                self.title = "채팅 - 연결 끊김"
            }
        }
        
        // 타이핑 상태 감지
        viewModel.onUserTyping = { [weak self] userId in
            guard let self = self else { return }
            
            // 간단한 타이핑 표시 구현
            self.typingIndicatorLabel.text = "상대방이 입력 중..."
            
            // 3초 후 타이핑 표시 제거
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.typingIndicatorLabel.text = ""
            }
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
    
    private func setupKeyboardObservers() {
        // 키보드 표시 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        // 키보드 숨김 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        // 키보드 높이만큼 입력 영역 위로 올림
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        messageInputBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // 테이블뷰 스크롤을 최신 메시지로 이동
        if !viewModel.messages.isEmpty {
            let lastRow = viewModel.messages.count - 1
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // 입력 영역을 원래 위치로 복원
        messageInputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func connectToRoom() {
        loadingIndicator.startAnimating()
        
        viewModel.connectToRoom { [weak self] result in
            guard let self = self else { return }
            
            self.loadingIndicator.stopAnimating()
            
            switch result {
            case .success:
                // 성공적으로 연결됨 - 상태 표시
                self.title = "채팅 - 연결됨"
            case .failure(let error):
                // 연결 실패 - 에러 표시
                let alert = UIAlertController(
                    title: "연결 실패",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in
                    self.connectToRoom()
                })
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func sendMessage() {
        guard let text = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }
        
        // 입력 필드 비우기
        messageTextField.text = ""
        
        // 메시지 전송
        viewModel.sendMessage(content: text) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                // 전송 실패 - 에러 표시
                let alert = UIAlertController(
                    title: "메시지 전송 실패",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < viewModel.messages.count {
            let message = viewModel.messages[indexPath.row]
            let isFromCurrentUser = viewModel.isMessageFromCurrentUser(message: message)
            
            cell.configure(with: message, isFromCurrentUser: isFromCurrentUser)
        }
        
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension ChatRoomVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 타이핑 상태 전송
        viewModel.sendTypingStatus(isTyping: true)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}