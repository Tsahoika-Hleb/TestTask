import UIKit

protocol PhotoListPresenterSpec {
    var elementsCount: Int { get }
    var data: [CellViewModel] { get set }
    
    func getData()
}

final class PhotoListPresenter: PhotoListPresenterSpec {
    
    // MARK: - Properties
    
    private weak var delegate: PhotoListViewControllerSpec?
    
    private let networkManager: NetworkManager?
    
    var data: [CellViewModel] = []
    private var contentData: [Content] = []
    
    var elementsCount: Int {
        data.count
    }
    
    private var page = 0
    private var totalPages = 0
    
    // MARK: - Init
    
    init(delegate: PhotoListViewControllerSpec, networkManager: NetworkManager? = NetworkManager()) {
        self.delegate = delegate
        self.networkManager = networkManager
    }
    
    // MARK: - Methods
    
    func getData() {
        
        networkManager?.request(config: .downloadData(page: page),
                                responseHandler: DefaultResponseHandler()) { [weak self] (result: Result<APIResponse, Error>) in
            switch result {
            case .success(let success):
                self?.contentData = success.content
                self?.page = success.page
                self?.totalPages = success.totalPages
                
                self?.downloadImages()
                
                DispatchQueue.main.async {
                    self?.delegate?.updateTableView()
                }
            case .failure(let failure):
                fatalError(failure.localizedDescription)
            }
        }
    }
    
    private func downloadImages() {
        var i = elementsCount
        
        while i < contentData.count {
            let element = (i ,self.contentData[i])
            self.data.append(CellViewModel(image: nil,
                                           name: element.1.name,
                                           id: element.1.id))
            if contentData[element.0].image != nil {
                networkManager?.request(config: .downloadImage(id: contentData[element.0].id),
                                        responseHandler: DefaultResponseHandler(),
                                        isApiResponse: false) { [weak self] (result: Result<Data, Error>) in
                    switch result {
                    case .success(let success):
                        self?.data[element.0].image = UIImage(data: success)
                        DispatchQueue.main.async {
                            self?.delegate?.updateTableView()
                        }
                    case .failure(let failure):
                        fatalError(failure.localizedDescription)
                    }
                }
            }
            i += 1
        }
    }
}
