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
//    var nextSevenDaysDataFromRealm = Array<NextSevenDaysWeatherForecastInRealm>()
    
    // MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background.jpeg"))
        
        tableView.tableFooterView = UIView()
        
        if RealmDataAccessUtility.checkIfNextSevenDaysForecastPresentInRealm() {
            do {
                let realmReference = try Realm()
                let fetchedNextSevenDaysData = realmReference.objects(NextSevenDaysWeatherForecastInRealm.self)
//                nextSevenDaysDataFromRealm = Array(retrivedData)
                
                nextSevenDaysData.removeAll()
                
                for _ in 0...6 {
                    nextSevenDaysData.append(Daily(dt: 0, sunrise: 0, sunset: 0, temp: Temp(day: 0.0, min: 0.0, max: 0.0, night: 0.0, eve: 0.0, morn: 0.0), feels_like: feels_like(day: 0.0, night: 0.0, eve: 0.0, morn: 0.0), pressure: 0, humidity: 0, dew_point: 0.0, wind_speed: 0.0, wind_deg: 0, weather: [Weather(id: 0, main: "", description: "", icon: "")], clouds: 0, uvi: 0.0))
                }
                
                for item in 0..<fetchedNextSevenDaysData.count {
                    nextSevenDaysData[item].dt = fetchedNextSevenDaysData[item].date_time
                    nextSevenDaysData[item].weather[0].icon = fetchedNextSevenDaysData[item].weather[0].weather_icon
                    nextSevenDaysData[item].weather[0].description = fetchedNextSevenDaysData[item].weather[0].weather_description
                    nextSevenDaysData[item].temp.max = fetchedNextSevenDaysData[item].temperature?.max_temperature ?? 0.0
                    nextSevenDaysData[item].temp.min = fetchedNextSevenDaysData[item].temperature?.min_temperature ?? 0.0
                }
            } catch {
                print("Error in Retrieving previous data!")
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
        
        cell.selectionStyle = .none

        if indexPath.row <= 6 {
            cell.forecastDate.text = "\(self.nextSevenDaysData[indexPath.row].dt.fromUnixTimeToDate())"
            //                cell.forecastSunriseTime.text = "Sunrise: " + self.NextSevenDaysData[indexPath.row].sunrise.fromUnixTimeToTime()
            //                cell.forecastSunsetTime.text = "Sunset: " + self.NextSevenDaysData[indexPath.row].sunset.fromUnixTimeToTime()
            //                cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
            let urlString = "https://openweathermap.org/img/wn/" + self.nextSevenDaysData[indexPath.row].weather[0].icon + ".png"
            let url = URL(string: urlString)
            cell.forecastWeatherIcon.imageLoad(from: url!)
            cell.forecastWeatherDescription.text = "" + self.nextSevenDaysData[indexPath.row].weather[0].description.capitalized
            cell.forecastMaxTemp.text = "Max: \(self.nextSevenDaysData[indexPath.row].temp.max)°C"
            cell.forecastMinTemp.text = "Min: \(self.nextSevenDaysData[indexPath.row].temp.min)°C"
            //            }
        }
        
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
