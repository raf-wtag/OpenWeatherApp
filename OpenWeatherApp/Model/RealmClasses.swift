//
//  RealmWeatherAppData.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 24/5/21.
//

import Foundation
import RealmSwift

class CityNameAndLocationInfoInRealm: Object {
    @objc dynamic var stored_cityName: String = ""
    @objc dynamic var stored_latitude: Double = 0.0
    @objc dynamic var stored_longitude: Double = 0.0
}

class NextSevenDaysWeatherForecastInRealm: Object {
    @objc dynamic var date_time: Int = 0
    @objc dynamic var temperature: TemperatureResponseInRealm?
    var weather: List<WeatherDetailsInRealm> = List<WeatherDetailsInRealm>()
}

class TemperatureResponseInRealm: Object {
    @objc dynamic var max_temperature: Double = 0.0
    @objc dynamic var min_temperature: Double = 0.0
}

//class NextSevenDaysWeatherDetailsInRealm: Object {
//    @objc dynamic var weather_details: WeatherDetailsInRealm? = WeatherDetailsInRealm()
//}

class PresentDayWeatherForecastInRealm: Object {
    @objc dynamic var dt: Int = 0
    @objc dynamic var sunrise : Int = 0
    @objc dynamic var sunset : Int = 0
    @objc dynamic var temp : Double = 0.0
    @objc dynamic var feels_like : Double = 0.0
    var weather: List<WeatherDetailsInRealm> = List<WeatherDetailsInRealm>()
}

//class PresentDayWeatherDetailsInRealm: Object {
//    @objc dynamic var weather_details: WeatherDetailsInRealm? = WeatherDetailsInRealm()
//}

class PresentDayHourlyWeatherForecastInRealm: Object {
    @objc dynamic var dt: Int = 0
    @objc dynamic var temp: Double = 0.0
    @objc dynamic var feels_like: Double = 0.0
    var weather: List<WeatherDetailsInRealm> = List<WeatherDetailsInRealm>()
}

//class PresentDayHourlyWeatherDetailsInRealm: Object {
//    @objc dynamic var weather_details: WeatherDetailsInRealm? = WeatherDetailsInRealm()
//}

class PresentDayTimezoneOffsetInRealm: Object {
    @objc dynamic var timezone_offset: String = ""
}

class WeatherDetailsInRealm: Object, Codable {
    @objc dynamic var weather_description: String = ""
    @objc dynamic var weather_icon: String = ""
}
