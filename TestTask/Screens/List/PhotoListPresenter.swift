import UIKit

protocol PhotoListPresenterSpec {
    var elementsCount: Int { get }
    var data: [CellViewModel] { get set }
    var isNowLoading: Bool { get set }
    
    func getData()
    func uploadImage(id: Int, imageData: Data)
}

final class PhotoListPresenter: PhotoListPresenterSpec {
    
    // MARK: - Properties
    
    private weak var delegate: PhotoListViewControllerSpec?
    
    private let networkManager: NetworkManager?
    
    var data: [CellViewModel] = []
    private var contentData: [Content] = []
    
    var isNowLoading: Bool = false
    
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
        guard totalPages >= page else { return }
            
        isNowLoading = true
        
        networkManager?.request(config: .downloadData(page: page),
                                responseHandler: DefaultResponseHandler()) { [weak self] (result: Result<APIResponse, Error>) in
            switch result {
            case .success(let success):
                self?.contentData += success.content
                self?.page = success.page + 1
                self?.totalPages = success.totalPages
                
                self?.downloadImages()
                
                DispatchQueue.main.async {
                    self?.delegate?.updateTableView()
                    self?.isNowLoading = false
                }
            case .failure(let failure):
                fatalError(failure.localizedDescription)
            }
        }
    }
    
    func uploadImage(id: Int, imageData: Data) {
        networkManager?.request(config: .uploadData(model: APIRequestBody(photo: imageData, typeId: id)), 
                                responseHandler: DefaultResponseHandler(),
                                isApiResponse: false) { (result: Result<String, Error>) in
            switch result {
            case .success(let success):
                 debugPrint(success)
            case .failure(let failure):
                fatalError(failure.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Methods
    
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
