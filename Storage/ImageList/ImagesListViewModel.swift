import Foundation
import Combine


class ImagesListViewModel {
    
    @Published private(set) var images: [ImagesListModel] = []
    @Published var errorMessage: String?
    
    private let networkManager: ImagesListNetworkProtocol
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var navigateToNextScreen = PassthroughSubject<Void, Never>()
        
    init(networkManager: ImagesListNetworkProtocol) {
        self.networkManager = networkManager
    }
    
    /// Fetches all image data from the server.
    func getAllImagesData() {
        networkManager.fetchImagesData(model: [ImagesListModel].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    print("Successfully fetched data")
                case .failure(let error):
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] imagesData in
                self?.images = imagesData
            }
            .store(in: &subscriptions)
    }
    

    func buttonDidTapped() {
        navigateToNextScreen.send()
    }
    

    func addNewImageURL(_ url: String) {
        guard !images.contains(where: { $0.url == url }) else {
            errorMessage = "Image with this URL already exists."
            return
        }
        images.insert(ImagesListModel(url: url), at: images.endIndex)
    }
    

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        print("Error: \(error.localizedDescription)")
    }
    
}

protocol ImagesListNetworkProtocol {
    func fetchImagesData<T: Codable>(model: T.Type) -> AnyPublisher<T, Error>
    func fetchImage(imageURL: String) -> ImageDownloadPublisher
    var activeDownloads: [URLSessionTask: Download] { get set }
}
