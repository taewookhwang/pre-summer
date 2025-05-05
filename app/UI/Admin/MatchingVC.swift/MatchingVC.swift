import UIKit

class MatchingVC: UIViewController {
    var viewModel: MatchingViewModel!
    weak var coordinator: AdminCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "서비스 매칭"
        setupUI()
    }
    
    private func setupUI() {
        // 기본 UI 설정 (실제 구현 시 완성)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "서비스 매칭 화면 (개발 중)"
        label.textAlignment = .center
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}