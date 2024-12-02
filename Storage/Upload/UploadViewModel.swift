import Foundation
import Combine

class MediaUploadViewModel {
    
    enum ImageProcessState {
        case idle
        case loading
        case optimizing
        case ready
        case uploadingOnServer
    }
    
    @Published private(set) var imageData: (Data?, String)?
    @Published private(set) var processState: ImageProcessState = .idle
    @Published private(set) var requestError: String = ""
    @Published private(set) var requestResultMessage: String = ""
    
    private let networkService: MediaUploadNetworkProtocol
    private var subscriptions: Set<AnyCancellable> = []
    
    init(networkService: MediaUploadNetworkProtocol) {
        self.networkService = networkService
    }
    
    func getImageBaseOnURL(_ url: String) {
        processState = .loading
        
        networkService.getImageFromUrl(from: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    print("Success to get image")
                    self?.processState = .idle 
                case .failure(let error):
                    self?.processState = .idle
                    self?.requestError = "Failed to load image: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] data in
                self?.processState = .optimizing
                DispatchQueue.global().async {
                    let compressedData = data.compression()
                    DispatchQueue.main.async {
                        self?.imageData = (compressedData, url)
                        self?.processState = .ready
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    func uploadImage(with imageData: Data) {
        processState = .uploadingOnServer
        
        networkService.uploadImageToServer(imageData: imageData)
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .finished:
                    print("Uploaded to server")
                case .failure(let error):
                    print("Upload error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] serverResponse in
                self?.processState = .ready
                self?.requestResultMessage = serverResponse
            }
            .store(in: &subscriptions)
    }
}
