import UIKit

class PaymentReportVC: UIViewController {
    // MARK: - Properties
    
    weak var coordinator: AdminCoordinator?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PaymentReportCell")
        return tableView
    }()
    
    private lazy var dateRangeSegmentedControl: UISegmentedControl = {
        let items = ["Daily", "Weekly", "Monthly"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(dateRangeChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Payment Reports"
        
        view.addSubview(dateRangeSegmentedControl)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            dateRangeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dateRangeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateRangeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: dateRangeSegmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func dateRangeChanged(_ sender: UISegmentedControl) {
        // Update the displayed report based on selected date range
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource

extension PaymentReportVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10  // Placeholder for demo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentReportCell", for: indexPath)
        cell.textLabel?.text = "Payment Report \(indexPath.row + 1)"
        return cell
    }
}