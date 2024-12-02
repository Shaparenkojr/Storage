import UIKit

extension Data {
    

    func compression() -> Data? {
        guard let image = UIImage(data: self) else { return nil }
        let targetSize = 1 * 1024 * 1024
        let minCompression: CGFloat = 0.1
        var compression: CGFloat = 1.0
        var compressedData = self
        

        if self.count < targetSize {
            return self
        }
        

        while compression > minCompression {
            if let data = image.jpegData(compressionQuality: compression) {
                compressedData = data
                if compressedData.count <= targetSize {
                    return compressedData
                }
            }
            compression -= 0.1
        }
   
        return compressedData
    }
}

