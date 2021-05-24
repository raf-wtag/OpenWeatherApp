//
//  RealmWeatherAppData.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 24/5/21.
//

import Foundation
import RealmSwift

class StoredWeatherInfos: Object {
    
    @objc dynamic var stored_cityName: String = ""
    @objc dynamic var stored_latitude: Double = 0.0
    @objc dynamic var stored_longitude: Double = 0.0
    
}

class StoredWeeklyWeatherInfos: Object {
    @objc dynamic var stored_weekDate: String = ""
    @objc dynamic var stored_weatherIcon: String = ""
    @objc dynamic var stored_weatherDescription: String = ""
    @objc dynamic var stored_maxTemp: String = ""
    @objc dynamic var stored_minTemp: String = ""
    
}
