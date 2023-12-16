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
        imageView.image = UIImage(named: "emptyImage")
        
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
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            idLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        
        return stackView
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
        contentView.addSubview(labelsStackView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        cellImageView.snp.makeConstraints { make in
            make.size.equalTo(Constants.imageSize)
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(15)
        }
        
        labelsStackView.snp.updateConstraints { make in
            make.left.equalTo(cellImageView.snp.right).offset(Constants.stackViewEdgeInsets.left)
            make.top.equalToSuperview().inset(Constants.stackViewEdgeInsets)
        }
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        idLabel.text = ""
        cellImageView.image = nil
        
        labelsStackView.removeArrangedSubview(titleLabel)
        labelsStackView.removeArrangedSubview(idLabel)
    }
    
    // MARK: - Iternal
    
    func configure(viewModel: CellViewModel) {
        if let image = viewModel.image {
            cellImageView.image = image
        }
        titleLabel.text = viewModel.name
        idLabel.text = String(viewModel.id)
    }
}

struct CellViewModel {
    let image: UIImage?
    let name: String
    let id: Int
}
