//
//  RealmWeatherAppData.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 24/5/21.
//

import Foundation
import RealmSwift

class SaveWeatherInfos: Object {
    
    @objc dynamic var stored_cityName: String = ""
    @objc dynamic var stored_latitude: Double = 0.0
    @objc dynamic var stored_longitude: Double = 0.0
    
    
    
}
