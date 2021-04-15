//
//  Extensions.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 31/3/21.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension Int {

    func  fromUnixTimeToDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    func  fromUnixTimeToTime() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    func  fromUnixTimeToTimeNDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm:ss a"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
}


extension UIImageView {
    
    func imageLoad(from url: URL) {
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            print("Now Fetching From Cache")
            self.image =  imageFromCache
            return
        }
        print("In Extension")
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url as AnyObject)
                    print("Now Fetching from url")
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
}
