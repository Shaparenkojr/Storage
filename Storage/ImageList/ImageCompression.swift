

import UIKit

extension Data {
    
    func compression() -> Data? {
        guard let imageWithData = UIImage(data: self) else { return nil }
        var currentData = self
        let targetSize = 1 * 1024 * 1024
        var compression: CGFloat = 1.0
        
        if self.count < targetSize {
            return self
        }
        
        while self.count > targetSize && compression > 0.1 {
            compression -= 0.1
            if let compressedData = imageWithData.jpegData(compressionQuality: compression) {
                currentData = compressedData
            } 
        }
        return currentData
    }
}
