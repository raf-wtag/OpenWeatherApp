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

class StoredDailyWeatherForecasts: Object {
    @objc dynamic var date_time: Int = 0
    @objc dynamic var temperature: TemperatureResponse?
    var weather: List<WeatherResponse> = List<WeatherResponse>()
}

class TemperatureResponse: Object {
    @objc dynamic var max_temperature: Double = 0.0
    @objc dynamic var min_temperature: Double = 0.0
}

class WeatherResponse: Object, Codable {
    @objc dynamic var weather_description: String = ""
    @objc dynamic var weather_icon: String = ""
}
