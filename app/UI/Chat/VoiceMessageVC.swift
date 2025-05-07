import UIKit

class VoiceMessageVC: UIViewController {
    // UI Components
    private let recordButton = UIButton(type: .system)
    private let timerLabel = UILabel()
    private let sendButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // 녹음 상태
    private var isRecording = false
    private var recordingDuration: TimeInterval = 0
    private var timer: Timer?
    
    // 콜백
    var onVoiceRecorded: ((Data, TimeInterval) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "음성 메시지"
        
        // 녹음 버튼
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("녹음 시작", for: .normal)
        recordButton.backgroundColor = .systemRed
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.layer.cornerRadius = 35
        recordButton.layer.borderWidth = 2
        recordButton.layer.borderColor = UIColor.systemGray.cgColor
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        view.addSubview(recordButton)
        
        // 타이머 레이블
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "00:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        timerLabel.textAlignment = .center
        view.addSubview(timerLabel)
        
        // 전송 버튼
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("전송", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendVoiceMessage), for: .touchUpInside)
        sendButton.isEnabled = false
        view.addSubview(sendButton)
        
        // 취소 버튼
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.backgroundColor = .systemGray5
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            recordButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 40),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            sendButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 40),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func toggleRecording() {
        isRecording = !isRecording
        
        if isRecording {
            // 녹음 시작
            startRecording()
        } else {
            // 녹음 중지
            stopRecording()
        }
    }
    
    private func startRecording() {
        recordButton.setTitle("녹음 중지", for: .normal)
        recordButton.backgroundColor = .systemGray
        
        // 타이머 시작
        recordingDuration = 0
        updateTimerLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.recordingDuration += 1
            self.updateTimerLabel()
            
            // 최대 녹음 시간 (예: 60초)
            if self.recordingDuration >= 60 {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        
        recordButton.setTitle("다시 녹음", for: .normal)
        recordButton.backgroundColor = .systemRed
        
        isRecording = false
        sendButton.isEnabled = recordingDuration > 0
    }
    
    private func updateTimerLabel() {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc private func sendVoiceMessage() {
        // 더미 데이터 생성 - 실제로는 오디오 녹음 데이터 사용
        let dummyData = Data(repeating: 0, count: Int(recordingDuration * 1000))
        
        onVoiceRecorded?(dummyData, recordingDuration)
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        timer?.invalidate()
        dismiss(animated: true)
    }
}