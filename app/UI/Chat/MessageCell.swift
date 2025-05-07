import UIKit

class MessageCell: UITableViewCell {
    // UI Components
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let attachmentImageView = UIImageView()
    
    // Constraints that will change based on message source
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = nil
        timeLabel.text = nil
        attachmentImageView.image = nil
        attachmentImageView.isHidden = true
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // 메시지 버블 뷰 설정
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)
        
        // 메시지 텍스트 라벨 설정
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        bubbleView.addSubview(messageLabel)
        
        // 시간 라벨 설정
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        contentView.addSubview(timeLabel)
        
        // 첨부 이미지 뷰 설정
        attachmentImageView.translatesAutoresizingMaskIntoConstraints = false
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.layer.cornerRadius = 8
        attachmentImageView.layer.masksToBounds = true
        attachmentImageView.isHidden = true
        bubbleView.addSubview(attachmentImageView)
        
        // 버블 뷰 제약조건 - 방향은 configure 메서드에서 설정
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            attachmentImageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            attachmentImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            attachmentImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            attachmentImageView.heightAnchor.constraint(equalToConstant: 150),
            attachmentImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2),
            timeLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        // 기본값으로 왼쪽 정렬 (수신 메시지)
        leadingConstraint?.isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
    }
    
    func configure(with message: Message, isFromCurrentUser: Bool) {
        // 메시지 방향 설정 (발신자에 따라)
        configureMessageDirection(isFromCurrentUser: isFromCurrentUser)
        
        // 버블 색상 설정
        bubbleView.backgroundColor = isFromCurrentUser ? .systemBlue : .systemGray5
        
        // 텍스트 색상 설정
        messageLabel.textColor = isFromCurrentUser ? .white : .black
        
        // 메시지 내용 설정
        messageLabel.text = message.content
        
        // 시간 포맷
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // 첨부 파일 처리
        configureAttachment(for: message)
    }
    
    private func configureMessageDirection(isFromCurrentUser: Bool) {
        // 이전 제약조건 비활성화
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        
        if isFromCurrentUser {
            // 오른쪽 정렬 (발신 메시지)
            trailingConstraint?.isActive = true
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = false
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        } else {
            // 왼쪽 정렬 (수신 메시지)
            leadingConstraint?.isActive = true
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = false
        }
    }
    
    private func configureAttachment(for message: Message) {
        switch message.type {
        case .text:
            // 텍스트 메시지는 첨부 파일 없음
            attachmentImageView.isHidden = true
            
        case .image:
            // 이미지 메시지 처리
            attachmentImageView.isHidden = false
            
            // 실제 구현에서는 이미지 로드 로직 추가
            // 여기서는 간단한 더미 이미지 사용
            attachmentImageView.backgroundColor = .systemGray3
            
            // 이미지 URL이 있는 경우 로드 (실제 구현 시 Kingfisher 등 사용)
            if let _ = message.attachmentURL {
                // attachmentImageView.kf.setImage(with: URL(string: attachmentURL))
                
                // 더미 구현
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.attachmentImageView.backgroundColor = .systemGray2
                }
            }
            
        case .location:
            // 위치 메시지 처리
            attachmentImageView.isHidden = false
            attachmentImageView.backgroundColor = .systemGray3
            
            // 실제 구현에서는 지도 스냅샷 표시
            // 여기서는 더미 구현
            
        case .voice:
            // 음성 메시지 처리
            attachmentImageView.isHidden = true
            
            // 실제 구현에서는 오디오 플레이어 UI 추가
            // 여기서는 더미 구현
        }
    }
}