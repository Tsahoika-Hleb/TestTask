import UIKit

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
    
    var mock: [CellViewModel] = []
    
    // MARK: - Lifycycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setup() {
        self.view.addSubview(tableView)
        
        setupConstraints()
        
        mock.append(CellViewModel(image: UIImage(named: "1"), name: "Год", id: 1))
        mock.append(CellViewModel(image: UIImage(named: "2"), name: "Человек", id: 2))
        mock.append(CellViewModel(image: nil, name: "Время", id: 3))
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
        mock.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PhotoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        else {
            return UITableViewCell()
        }
        let cellModel = mock[indexPath.row]
        cell.configure(viewModel: cellModel)
        return cell
    }
}
