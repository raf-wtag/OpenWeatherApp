//
//  WeatherData.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import Foundation

struct WeatherData: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
//    let timezone_offset: Int
    var daily: [Daily]
    var current : Current
    var hourly: [Hourly]
    
    
    mutating func sortDailyArray() {
           daily.sort { (day1, day2) -> Bool in
               return day1.dt < day2.dt
           }
       }
    
}

struct Daily: Codable {
    var dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Temp
    let feels_like: feels_like
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
    let clouds: Int
//    let pop: Int?
    let uvi: Double
    
    
//    mutating func dateConvert() {
//        self.dt = Date(timeIntervalSince1970: Double(dt))
//    }
}


struct Temp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}


struct feels_like: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}


struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct SecretKeysMap: Codable {
    let APIKEY: String
}

struct Current: Codable {
    let dt : Int
    let sunrise : Int
    let sunset : Int
    let temp : Double // Error
    let feels_like : Double
    let weather : [Weather]
    
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
}
