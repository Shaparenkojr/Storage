

import Foundation
import Combine

class ImagesListViewModel {
    
    @Published private(set) var images: [ImagesListModel] = []
    
    private let networkManager: ImagesListNetworkProtocol
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var navigateToNextScreen = PassthroughSubject<Void, Never>()
        
    init(networkManager: ImagesListNetworkProtocol) {
        self.networkManager = networkManager
    }
    
    func getAllImagesData() {
        networkManager.fetchImagesData(model: [ImagesListModel].self)
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .finished:
                    print("success to get data")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { imagesData in
                self.images = imagesData
            }
            .store(in: &subscriptions)
    }
    
    func buttonDidTapped() {
        navigateToNextScreen.send()
    }
    
    func addNewImageURL(_ url: String) {
        images.insert(ImagesListModel(url: url), at: images.endIndex)
    }
}
protocol ImagesListNetworkProtocol {
    func fetchImagesData<T: Codable>(model: T.Type) -> AnyPublisher<T, Error>
    func fetchImage(imageURL: String) -> ImageDownloadPublisher
    var activeDownloads: [URLSessionTask: Download] { get set }
}
