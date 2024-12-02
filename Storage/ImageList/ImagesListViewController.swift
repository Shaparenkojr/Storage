import UIKit
import Combine

class ImagesViewController: UIViewController {
    
    private lazy var imagesListView: ImagesListView = {
        let view = ImagesListView(frame: .zero, viewModel: viewModel, CellViewModel: CellViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: ImagesListViewModel
    private let CellViewModel: CellViewModel
    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupBindings()
        viewModel.getAllImagesData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    init(viewModel: ImagesListViewModel, CellViewModel: CellViewModel) {
        self.viewModel = viewModel
        self.CellViewModel = CellViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImagesViewController {
    
    func setupBindings() {
        viewModel.$images
            .sink { [weak self] images in
                self?.imagesListView.getImagesSize(imagesData: images)
            }
            .store(in: &subscriptions)
        
        viewModel.navigateToNextScreen
            .sink { [weak self] _ in
                self?.showNextScreen()
            }
            .store(in: &subscriptions)
    }
    
    func showNextScreen() {
        let mediaUploadNetworkService: MediaUploadNetworkProtocol = NetworkService()
        let mediaUploadViewModel = MediaUploadViewModel(networkService: mediaUploadNetworkService)
        let mediaUploadViewContoller = MediaUploadViewController(viewModel: mediaUploadViewModel, imagesListViewModel: viewModel)
        self.navigationController?.pushViewController(mediaUploadViewContoller, animated: true)
    }
    
    func setupController() {
        view.backgroundColor = .white
        
        view.addSubview(imagesListView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imagesListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imagesListView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imagesListView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imagesListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
}

private extension NavigationController {
    
    func setupNavigation() {
        let networkManager: ImagesListNetworkProtocol = NetworkService()
        let imagesViewModel = ImagesListViewModel(networkManager: networkManager)
        let CellViewModel = CellViewModel(networkManager: networkManager)
        let imagesListController = ImagesViewController(viewModel: imagesViewModel, CellViewModel: CellViewModel)
        viewControllers = [imagesListController]
    }
    
}

