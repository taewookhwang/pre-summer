import UIKit

class LocationShareVC: UIViewController {
    // UI Components
    private let mapView = UIView() // 실제 구현에서는 MKMapView 등 사용
    private let sendButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // Callback
    var onLocationSelected: ((Double, Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "위치 공유"
        
        // 간단한 지도 뷰 구현 (실제로는 MapKit 사용)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.backgroundColor = .systemGray5
        view.addSubview(mapView)
        
        // 위치 전송 버튼
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("이 위치 공유하기", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
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
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            sendButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 간단한 지도 표시 (더미)
        let pinView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        pinView.backgroundColor = .systemRed
        pinView.layer.cornerRadius = 10
        mapView.addSubview(pinView)
        pinView.center = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
    }
    
    @objc private func sendLocation() {
        // 더미 좌표 - 실제 구현에서는 맵에서 선택한 위치 사용
        let latitude = 37.5665
        let longitude = 126.9780
        
        onLocationSelected?(latitude, longitude)
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}