import Foundation
import Combine

class ImageCellViewModel {
    
    @Published private(set) var imageData: [String : Data] = [:]
    @Published private(set) var imageDataProgress: [String : Float] = [:]
    
    private var imageUrl: String?
    private var subscriptions: Set<AnyCancellable> = []
    private let networkManager: ImagesListNetworkProtocol
    
    init(networkManager: ImagesListNetworkProtocol) {
        self.networkManager = networkManager
    }
    
    func loadImage(from url: String) {
        let downloadPublisher = networkManager.fetchImage(imageURL: url)
        
        downloadPublisher.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Фото загружено")
                case .failure(let error):
                    print("Ошибка: \(error)")
                }
            } receiveValue: { [weak self] data in
                self?.imageData[url] = data
            }
            .store(in: &subscriptions)
        
        downloadPublisher.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.imageDataProgress[url] = progress
            }
            .store(in: &subscriptions)
    }
}
