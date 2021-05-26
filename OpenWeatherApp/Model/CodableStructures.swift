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



struct Current: Codable {
    var dt : Int
    let sunrise : Int
    let sunset : Int
    let temp : Double 
    let feels_like : Double
    let weather : [Weather]
    
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
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

