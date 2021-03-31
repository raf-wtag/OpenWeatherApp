//
//  Extensions.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 31/3/21.
//

import Foundation
import UIKit

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
        dateFormatter.dateFormat = "MMM d, h:mm a"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    
}

extension UIImageView {
    
    func load(urlString: String) {
        print("Firstly Extension",urlString)
        guard let url = URL(string: urlString) else {
            print("Extension in Failed")
            return
        }
        print("In Extension")
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
}
