import Combine
import Foundation
struct ImagesListModel: Codable {
    let url: String
}

struct ImageDownloadPublisher {
    let dataPublisher: AnyPublisher<Data, Error>
    let progressPublisher: AnyPublisher<Float, Never>
}

struct Download {
    let task: URLSessionDownloadTask
    let progressPublisher: PassthroughSubject<Float, Never>
    let promise: (Result<Data, Error>) -> Void
}
