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
    var nextSevenDaysDataFromRealm = Array<NextSevenDaysWeatherForecastInRealm>()
    
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
                let retrivedData = realmReference.objects(NextSevenDaysWeatherForecastInRealm.self)
                nextSevenDaysDataFromRealm = Array(retrivedData)
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
        if IsWeeklyDataSourceRealm() {
            return nextSevenDaysDataFromRealm.count
        }
        return nextSevenDaysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! CustomTableViewCell
        
        cell.selectionStyle = .none
        
        if IsWeeklyDataSourceRealm() {
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
//                cell.forecastSunriseTime.text = "Sunrise: " + self.NextSevenDaysData[indexPath.row].sunrise.fromUnixTimeToTime()
//                cell.forecastSunsetTime.text = "Sunset: " + self.NextSevenDaysData[indexPath.row].sunset.fromUnixTimeToTime()
//                cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
                let urlString = "https://openweathermap.org/img/wn/" + self.nextSevenDaysData[indexPath.row].weather[0].icon + ".png"
                let url = URL(string: urlString)
                cell.forecastWeatherIcon.imageLoad(from: url!)
                cell.forecastWeatherDescription.text = "" + self.nextSevenDaysData[indexPath.row].weather[0].description.capitalized
                cell.forecastMaxTemp.text = "Max: \(self.nextSevenDaysData[indexPath.row].temp.max)°C"
                cell.forecastMinTemp.text = "Min: \(self.nextSevenDaysData[indexPath.row].temp.min)°C"
            }
        }
        
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func IsWeeklyDataSourceRealm() -> Bool {
        if nextSevenDaysData.count == 0 {
            return true
        }
        return false
    }
}
