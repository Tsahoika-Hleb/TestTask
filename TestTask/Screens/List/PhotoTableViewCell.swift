import UIKit
import SnapKit

private enum Constants {
    static let imageSize = CGSize(width: 100, height: 100)
    static let stackViewEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 14)
}

final class PhotoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    private var idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(idLabel)
        
        setupConstraints()
    }

    private func setupConstraints() {
        cellImageView.snp.makeConstraints { make in
            make.size.equalTo(Constants.imageSize)
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.left.equalTo(cellImageView.snp.right).offset(20)
        }
        
        idLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(15)
            make.left.equalTo(cellImageView.snp.right).offset(20)
        }

    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        idLabel.text = ""
        cellImageView.image = nil
    }
    
    // MARK: - Iternal
    
    func configure(viewModel: CellViewModel) {
        if let image = viewModel.image {
            cellImageView.image = image
        } else {
            cellImageView.image = UIImage(named: "emptyImage")
        }
        titleLabel.text = viewModel.name
        idLabel.text = String(viewModel.id)
    }
}

struct CellViewModel {
    var image: UIImage?
    let name: String
    let id: Int
}
