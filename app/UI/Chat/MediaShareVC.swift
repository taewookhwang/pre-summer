import UIKit

class MediaShareVC: UIViewController {
    // UI Components
    private let imagePreviewView = UIImageView()
    private let sendButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // Properties
    private var selectedImageData: Data?
    
    // Callback
    var onImageSelected: ((Data) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "이미지 공유"
        
        // 이미지 미리보기
        imagePreviewView.translatesAutoresizingMaskIntoConstraints = false
        imagePreviewView.contentMode = .scaleAspectFit
        imagePreviewView.backgroundColor = .systemGray6
        view.addSubview(imagePreviewView)
        
        // 전송 버튼
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("이미지 보내기", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
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
        
        // 이미지 선택 버튼
        let selectButton = UIButton(type: .system)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.setTitle("이미지 선택하기", for: .normal)
        selectButton.backgroundColor = .systemGray
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.layer.cornerRadius = 8
        selectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        view.addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            imagePreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imagePreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imagePreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imagePreviewView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            selectButton.topAnchor.constraint(equalTo: imagePreviewView.bottomAnchor, constant: 20),
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func selectImage() {
        // 더미 구현 - 실제로는 UIImagePickerController 사용
        // 여기서는 테스트용으로 더미 이미지 사용
        
        // 테스트용 더미 이미지 설정
        let dummyImage = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        dummyImage.backgroundColor = .systemBlue
        
        // 텍스트 라벨 추가
        let label = UILabel(frame: dummyImage.bounds)
        label.text = "테스트 이미지"
        label.textAlignment = .center
        label.textColor = .white
        dummyImage.addSubview(label)
        
        UIGraphicsBeginImageContextWithOptions(dummyImage.bounds.size, false, 0.0)
        dummyImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image, let data = image.pngData() {
            imagePreviewView.image = image
            selectedImageData = data
            sendButton.isEnabled = true
        }
    }
    
    @objc private func sendImage() {
        guard let imageData = selectedImageData else { return }
        
        onImageSelected?(imageData)
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}