
import Foundation
import UIKit

class Memory {
    
    static let shared = Memory()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func saveImageToMemory(_ cachedImage: UIImage, for url: String) {
        cache.setObject(cachedImage, forKey: NSString(string: url))
    }
    
    func getImageFromMemory(for url: String) -> UIImage? {
        return cache.object(forKey: NSString(string: url))
    }
}
