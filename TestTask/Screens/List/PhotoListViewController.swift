import UIKit

protocol PhotoListViewControllerSpec: AnyObject {
    func updateTableView()
}

final class PhotoListViewController: UIViewController {

    // MARK: - Properties
    
    var presenter: PhotoListPresenterSpec?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: PhotoTableViewCell.self)
        
        return tableView
    }()
    
    // MARK: - Lifycycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        self.view.addSubview(tableView)
        
        setupConstraints()
        
        presenter?.getData()
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension PhotoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.elementsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter, let cell: PhotoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        else {
            return UITableViewCell()
        }
        let cellModel = presenter.data[indexPath.row]
        cell.configure(viewModel: cellModel)
        return cell
    }
}

// MARK: - PhotoListViewControllerSpec

extension PhotoListViewController: PhotoListViewControllerSpec {
    
    func updateTableView() {
        self.tableView.reloadData()
    }
}
