
import Foundation
import Combine

protocol MediaUploadNetworkProtocol {
    func getImageFromUrl(from url: String) -> AnyPublisher<Data, Error>
    func uploadImageToServer(imageData: Data) -> AnyPublisher<String, Error>
}

class NetworkService: NSObject, ImagesListNetworkProtocol, MediaUploadNetworkProtocol {
    
    enum NetworkErrors: Error {
        case invalidURL
        case invalidData
        case badServiceResponse
        case serverError(Int)
        case invalidResponseData
    }
    
    var activeDownloads: [URLSessionTask: Download] = [:]
    
    func fetchImagesData<T: Codable>(model: T.Type) -> AnyPublisher<T, Error> {
        guard let request = createRequest(with: "http://164.90.163.215:1337/api/upload/files", for: "GET") else {
            return Fail(error: NetworkErrors.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(imageURL: String) -> ImageDownloadPublisher {
        guard let request = createRequest(with: "http://164.90.163.215:1337\(imageURL)", for: "GET") else {
            let dataPublisher = Fail<Data, Error>(error: NetworkErrors.invalidURL)
                .eraseToAnyPublisher()
            let progressPublisher = Empty<Float, Never>().eraseToAnyPublisher()
            return ImageDownloadPublisher(dataPublisher: dataPublisher, progressPublisher: progressPublisher)
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: request)
        let progressPublisher = PassthroughSubject<Float, Never>()
        
        let dataPublisher = Deferred {
            Future<Data, Error> { promise in
                let download = Download(task: downloadTask,
                                        progressPublisher: progressPublisher,
                                        promise: promise)
                self.activeDownloads[downloadTask] = download
                downloadTask.resume()
            }
        }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return ImageDownloadPublisher(dataPublisher: dataPublisher,
                                      progressPublisher: progressPublisher.eraseToAnyPublisher())
    }
    
    func getImageFromUrl(from url: String) -> AnyPublisher<Data, Error> {
        guard let request = createRequest(with: url, for: "GET") else {
            return Fail(error: NetworkErrors.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { $0.data }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadImageToServer(imageData: Data) -> AnyPublisher<String, Error> {
        guard var request = createRequest(with: "http://164.90.163.215:1337/api/upload", for: "POST") else {
            return Fail(error: NetworkErrors.invalidURL)
                .eraseToAnyPublisher()
        }
        let boundary = UUID().uuidString
        let headers: [String: String] = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Authorization")
        
        let imageName = UUID().uuidString
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(imageName).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> String in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkErrors.badServiceResponse
                }
                
                if httpResponse.statusCode == 200 {
                    return "Success to upload"
                } else {
                    throw NetworkErrors.serverError(httpResponse.statusCode)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NetworkService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard let download = activeDownloads[downloadTask] else { return }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.progressPublisher.send(progress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let download = activeDownloads[downloadTask] else { return }
        do {
            let data = try Data(contentsOf: location)
            download.promise(.success(data))
        } catch {
            download.promise(.failure(NetworkErrors.invalidData))
        }
        download.progressPublisher.send(completion: .finished)
        activeDownloads[downloadTask] = nil
    }
}

private extension NetworkService {
    
    func createRequest(with url: String, for httpMethod: String) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        let authToken = "11c211d104fe7642083a90da69799cf055f1fe1836a211aca77c72e3e069e7fde735be9547f0917e1a1000efcb504e21f039d7ff55bf1afcb9e2dd56e4d6b5ddec3b199d12a2fac122e43b4dcba3fea66fe428e7c2ee9fc4f1deaa615fa5b6a68e2975cd2f99c65a9eda376e5b6a2a3aee1826ca4ce36d645b4f59f60cf5b74a"
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(authToken)"]
        return request
    }
    
}
