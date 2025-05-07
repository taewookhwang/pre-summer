import UIKit

class UserManagementVC: UIViewController {
    var viewModel: UserManagementViewModel!
    weak var coordinator: AdminCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "사용자 관리"
        setupUI()
    }
    
    private func setupUI() {
        // 기본 UI 설정 (실제 구현 시 완성)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "사용자 관리 화면 (개발 중)"
        label.textAlignment = .center
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}