import Foundation
import Combine

class CellViewModel {
    
    @Published private(set) var imageData: [String: Data] = [:]
    @Published private(set) var imageDataProgress: [String: Float] = [:]
    @Published var lastError: Error? 
    
    private var subscriptions: Set<AnyCancellable> = []
    private let networkManager: ImagesListNetworkProtocol
    
    init(networkManager: ImagesListNetworkProtocol) {
        self.networkManager = networkManager
    }
    
    
    func loadImage(from url: String) {
        let downloadPublisher = networkManager.fetchImage(imageURL: url)
        
        downloadPublisher.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("Image successfully loaded from \(url)")
                case .failure(let error):
                    print("Error loading image from \(url): \(error)")
                    self?.lastError = error
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
