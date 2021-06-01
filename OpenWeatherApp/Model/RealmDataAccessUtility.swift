//
//  RealmDataAccessUtility.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 30/5/21.
//

import Foundation
import RealmSwift

class RealmDataAccessUtility {
    static func deleteCityNameAndCoordinateClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(CityNameAndLocationInfoInRealm.self))
            }
        } catch {
            print("Error in delete city name and location class data in realm")
        }
    }
    
    static func deletePresentDayHourlyWeatherForecastClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(PresentDayHourlyWeatherForecastInRealm.self))
//                realmReference.delete(realmReference.objects(PresentDayHourlyWeatherDetailsInRealm.self))
            }
        } catch {
            print("Error in delete nextSevenDayForecast class data in realm")
        }
    }
    
    static func deletePresentDayWeatherForecastClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(PresentDayWeatherForecastInRealm.self))
//                realmReference.delete(realmReference.objects(PresentDayWeatherDetailsInRealm.self))
            }
        } catch {
            print("Error in delete Present day weather forecast data from realm")
        }
    }
    
    static func deleteNextSevenDaysWeatherForecastClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(NextSevenDaysWeatherForecastInRealm.self))
                realmReference.delete(realmReference.objects(TemperatureResponseInRealm.self))
//                realmReference.delete(realmReference.objects(NextSevenDaysWeatherDetailsInRealm.self))
            }
        } catch {
            print("Error in delete next seven days weather forecast data from realm")
        }
    }
    
    static func deletePresentDayTimezoneOffsetClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(PresentDayTimezoneOffsetInRealm.self))
            }
        } catch {
            print("Error in delete next seven days weather forecast data from realm")
        }
    }
    
    static func deleteWeatherDetailsClassData() {
        do {
            let realmReference = try Realm()
            
            try realmReference.write {
                realmReference.delete(realmReference.objects(WeatherDetailsInRealm.self))
            }
        } catch {
            print("Error in delete next seven days weather forecast data from realm")
        }
    }
    

    static func saveCityNameAndCoordinatesForLocation(name: String, latitude: Double, longitude: Double) {
        do {
            let realmReference = try Realm()
            
            RealmDataAccessUtility.deleteCityNameAndCoordinateClassData()
            
            let storeCityNameAndLocationInfo = CityNameAndLocationInfoInRealm()
            storeCityNameAndLocationInfo.stored_cityName = name
            storeCityNameAndLocationInfo.stored_latitude = latitude
            storeCityNameAndLocationInfo.stored_longitude = longitude
            
            try realmReference.write {
                realmReference.add(storeCityNameAndLocationInfo)
            }
        } catch {
            print("Error Saving City name and Coordinates")
        }
    }
    
    static func savePresentDaysHourlyWeatherForecastFrom(data: [Hourly]) {
        do {
            let realmReference = try Realm()
            
            RealmDataAccessUtility.deletePresentDayHourlyWeatherForecastClassData()
            
            
            for item in data {
                let weatherResponseObject = List<WeatherDetailsInRealm>()
                let saveWeatherResponse = WeatherDetailsInRealm()
                saveWeatherResponse.weather_icon = item.weather[0].icon
                weatherResponseObject.append(saveWeatherResponse)
                
                let hourlyWeatherDataObject =  PresentDayHourlyWeatherForecastInRealm()
                hourlyWeatherDataObject.dt = item.dt
                hourlyWeatherDataObject.temp = item.temp
                hourlyWeatherDataObject.feels_like = item.feels_like
                hourlyWeatherDataObject.weather = weatherResponseObject
                
                try realmReference.write {
                    realmReference.add(hourlyWeatherDataObject)
                }
            }
        } catch {
            print("Error in saving Hourly data in Realm")
        }
    }
    
    static func savePresentDayWeatherForecastFrom(presentDayForecast: Current) {
        do {
            let realmReference = try Realm()
            
            RealmDataAccessUtility.deletePresentDayWeatherForecastClassData()
            
            let weatherResponseObject = List<WeatherDetailsInRealm>()
            let saveWeatherResponse = WeatherDetailsInRealm()
            saveWeatherResponse.weather_description = presentDayForecast.weather[0].description
            saveWeatherResponse.weather_icon = presentDayForecast.weather[0].icon
            weatherResponseObject.append(saveWeatherResponse)
            
            let currentWeatherDataObject =  PresentDayWeatherForecastInRealm()
            currentWeatherDataObject.dt = presentDayForecast.dt
            currentWeatherDataObject.sunrise = presentDayForecast.sunrise
            currentWeatherDataObject.sunset = presentDayForecast.sunset
            currentWeatherDataObject.temp = presentDayForecast.temp
            currentWeatherDataObject.feels_like = presentDayForecast.feels_like
            currentWeatherDataObject.weather = weatherResponseObject
            
            try realmReference.write {
                realmReference.add(currentWeatherDataObject)
            }
            
        } catch {
            print("Error in saving Current Weather Data")
        }
    }
    
    static func saveNextSevenDaysForecastFrom(data: [Daily]) {
        do {
            let realmReference = try Realm()
            
            RealmDataAccessUtility.deleteNextSevenDaysWeatherForecastClassData()
            
            for eachItem in data {
                let weatherList = List<WeatherDetailsInRealm>()
                let saveWeather = WeatherDetailsInRealm()
                saveWeather.weather_description = eachItem.weather.first?.description ?? ""
                saveWeather.weather_icon = eachItem.weather.first?.icon ?? ""
                weatherList.append(saveWeather)
                
                let saveTemperature = TemperatureResponseInRealm()
                saveTemperature.max_temperature = eachItem.temp.max
                saveTemperature.min_temperature = eachItem.temp.min
                
                let saveDailyWeatherForecast = NextSevenDaysWeatherForecastInRealm()
                saveDailyWeatherForecast.date_time = eachItem.dt
                saveDailyWeatherForecast.temperature = saveTemperature
                saveDailyWeatherForecast.weather = weatherList

                try realmReference.write {
                    realmReference.add(saveDailyWeatherForecast)
                }
            }
            
        } catch {
            print("Error in saving NextSevendaysData")
        }
    }
    
    static func savePresentDayTime(from identifier: String) {
        do {
            let realmReference = try Realm()
            
            RealmDataAccessUtility.deletePresentDayTimezoneOffsetClassData()
            
            let saveTimezoneIdentifier = PresentDayTimezoneOffsetInRealm()
            saveTimezoneIdentifier.timezone_offset = identifier
            
            try realmReference.write {
                realmReference.add(saveTimezoneIdentifier)
            }
            
        } catch {
            print("Error in saving timezone offset")
        }
    }
    
    static func checkIfNextSevenDaysForecastPresentInRealm() -> Bool {
        do {
            let realmReference = try Realm()
            let fetchedNextSevenDaysDataFromRealm = realmReference.objects(NextSevenDaysWeatherForecastInRealm.self)

            if fetchedNextSevenDaysDataFromRealm.count > 0 {
                return true
            }
        } catch {
            print("Error in Realm Integration in HomeViewController()")
        }
        return false
    }
    
    static func checkIfWeatherForcastsPresentInRealm() -> Bool{
        do {
            let realmReference = try Realm()
            print(Realm.Configuration.defaultConfiguration)
            
            let fetchedLocationDataFromRealm = realmReference.objects(CityNameAndLocationInfoInRealm.self)
            let fetchedCurrentWeatherDataFromRealm = realmReference.objects(PresentDayWeatherForecastInRealm.self)
            let fetchedPresentDayHourlyDataFromRealm = realmReference.objects(PresentDayHourlyWeatherForecastInRealm.self)
            
            if fetchedLocationDataFromRealm.count > 0,
               fetchedCurrentWeatherDataFromRealm.count > 0,
               fetchedPresentDayHourlyDataFromRealm.count > 0{
                return true
            }
        } catch {
            print("Error in Realm Integration in HomeViewController()")
        }
        return false
    }
}
