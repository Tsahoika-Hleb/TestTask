import UIKit

protocol PhotoListViewControllerSpec: AnyObject {
    func updateTableView()
}

final class PhotoListViewController: UIViewController {

    // MARK: - Properties
    
    var presenter: PhotoListPresenterSpec?
    
    private var selectedTableViewRow: Int?
    
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
    
    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let presenter else { return }
        
        if indexPath.row == presenter.elementsCount - 5, !presenter.isNowLoading {
            presenter.getData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTableViewRow = indexPath.row
        
         self.presentCamera()
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}


// MARK: - UIImageControllerDelegate & UINavigationControllerDelegate

extension PhotoListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    
        if let row = selectedTableViewRow, let id = presenter?.data[row].id, let data = image.pngData() {
            presenter?.uploadImage(id: id, imageData: data)
        }
        
        selectedTableViewRow = nil
    }
}


// MARK: - PhotoListViewControllerSpec

extension PhotoListViewController: PhotoListViewControllerSpec {
    
    func updateTableView() {
        self.tableView.reloadData()
    }
}
