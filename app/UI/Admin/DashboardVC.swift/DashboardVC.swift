import UIKit

class DashboardVC: UIViewController {
    var viewModel: DashboardViewModel!
    weak var coordinator: AdminCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "관리자 대시보드"
        setupUI()
    }
    
    private func setupUI() {
        // 기본 UI 설정 (실제 구현 시 완성)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "관리자 대시보드 (개발 중)"
        label.textAlignment = .center
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}