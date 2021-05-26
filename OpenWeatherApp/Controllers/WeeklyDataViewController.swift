//
//  WeeklyDataViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import RealmSwift
import Network

class WeeklyDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

//    var latitude = 0.0
//    var longitude = 0.0

    var nextSevenDaysData = [Daily]()
    var iconImage: UIImage? = nil
    let monitor = NWPathMonitor()
    var isReadForcastDataFromRealm = true
    var nextSevenDaysDataFromRealm = Array<StoredDailyWeatherForecasts>()
    
    // MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundView = UIImageView(image: UIImage(named: "background.jpeg"))
        
        if isReadForcastDataFromRealm {
            do {
                let realmReference = try Realm()
                let retrivedData = realmReference.objects(StoredDailyWeatherForecasts.self)
                nextSevenDaysDataFromRealm = Array(retrivedData)
                for item in nextSevenDaysDataFromRealm {
                    print(item)
                }
//                print(type(of: nextSevenDaysDataFromRealm))

//                realmReference.beginWrite()
//                realmReference.delete(realmReference.objects(StoredWeeklyWeatherInfos.self))
//                try realmReference.commitWrite()
            } catch {
                print("Error in Deleting previous data!")
            }
        }
    }
    
    // MARK:- TableView Part
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nextSevenDaysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! CustomTableViewCell
        
        if isReadForcastDataFromRealm {
            cell.forecastDate.text = "\(nextSevenDaysDataFromRealm[indexPath.row].date_time.fromUnixTimeToDate())"
            
            let urlString = "https://openweathermap.org/img/wn/" + nextSevenDaysDataFromRealm[indexPath.row].weather[0].weather_icon + ".png"
            let url = URL(string: urlString)
            cell.forecastWeatherIcon.imageLoad(from: url!)
            
            cell.forecastWeatherDescription.text = "" + nextSevenDaysDataFromRealm[indexPath.row].weather[0].weather_description.capitalized
            if let max_temperature = nextSevenDaysDataFromRealm[indexPath.row].temperature?.max_temperature {
                cell.forecastMaxTemp.text = "Max: \(max_temperature)°C"
            }
            if let min_temperature = nextSevenDaysDataFromRealm[indexPath.row].temperature?.min_temperature {
                cell.forecastMinTemp.text = "Min: \(min_temperature)°C"
            }
           
            
        } else {
            
            if indexPath.row <= 6 {
                cell.forecastDate.text = "\(self.nextSevenDaysData[indexPath.row].dt.fromUnixTimeToDate())"
    //            cell.forecastSunriseTime.text = "Sunrise: " + self.NextSevenDaysData[indexPath.row].sunrise.fromUnixTimeToTime()
    //            cell.forecastSunsetTime.text = "Sunset: " + self.NextSevenDaysData[indexPath.row].sunset.fromUnixTimeToTime()
    //            cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
                let urlString = "https://openweathermap.org/img/wn/" + self.nextSevenDaysData[indexPath.row].weather[0].icon + ".png"
                let url = URL(string: urlString)
                cell.forecastWeatherIcon.imageLoad(from: url!)
                cell.forecastWeatherDescription.text = "" + self.nextSevenDaysData[indexPath.row].weather[0].description.capitalized
                cell.forecastMaxTemp.text = "Max: \(self.nextSevenDaysData[indexPath.row].temp.max)°C"
                cell.forecastMinTemp.text = "Min: \(self.nextSevenDaysData[indexPath.row].temp.min)°C"
                
    //            do {
    //                let realmReference = try Realm()
    //                let weeklyInfoObject = StoredWeeklyWeatherInfos()
    //                weeklyInfoObject.stored_weekDate = "\(self.nextSevenDaysData[indexPath.row].dt.fromUnixTimeToDate())"
    //                weeklyInfoObject.stored_weatherIcon = urlString
    //                weeklyInfoObject.stored_weatherDescription = "" + self.nextSevenDaysData[indexPath.row].weather[0].description.capitalized
    //                weeklyInfoObject.stored_maxTemp = "Max: \(self.nextSevenDaysData[indexPath.row].temp.max)°C"
    //                weeklyInfoObject.stored_minTemp = "Min: \(self.nextSevenDaysData[indexPath.row].temp.min)°C"
    //
    //                realmReference.beginWrite()
    //                realmReference.add(weeklyInfoObject)
    //                try realmReference.commitWrite()
    //
    //            } catch {
    //                print("Error in reference in weekly wether forecast")
    //            }
            }
        }
        
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
