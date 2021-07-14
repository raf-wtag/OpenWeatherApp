//
//  CodableStructures.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 14/4/21.
//

import Foundation

struct SecretKeysMap: Codable {
    let APIKEY_OPENWEATHERMAP: String
    let APIKEY_MAPBOX: String
}

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
    var sunrise: Int
    var sunset: Int
    var temp: Temp
    var feels_like: feels_like
    var pressure: Int
    var humidity: Int
    var dew_point: Double
    var wind_speed: Double
    var wind_deg: Int
    var weather: [Weather]
    var clouds: Int
//    let pop: Int?
    let uvi: Double
    
    
//    mutating func dateConvert() {
//        self.dt = Date(timeIntervalSince1970: Double(dt))
//    }
}


struct Temp: Codable {
    var day: Double
    var min: Double
    var max: Double
    var night: Double
    var eve: Double
    var morn: Double
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
    var description: String
    var icon: String
}



struct Current: Codable {
    var dt : Int
    var sunrise : Int
    var sunset : Int
    var temp : Double
    var feels_like : Double
    var weather : [Weather]
    
}

struct Hourly: Codable {
    var dt: Int
    var temp: Double
    var feels_like: Double
    var weather: [Weather]
}

struct Response: Codable {
    var features: [Feature]
}

struct Feature: Codable {
    var id: String!
    var type: String?
    var matching_place_name: String?
    var place_name: String?
    var geometry: Geometry
    var center: [Double]
    var properties: Properties
}

struct Geometry: Codable {
    var type: String?
    var coordinates: [Double]
}

struct Properties: Codable {
    var address: String?
}

