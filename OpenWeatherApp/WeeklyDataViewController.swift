//
//  WeeklyDataViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit

class WeeklyDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
//    var latitude = 0.0
//    var longitude = 0.0
    
    var NextSevenDaysData = [Daily]()
    
    var iconImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Declare the dataSource and Delegates
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    // MARK: TableView Part
    // Core Methods of TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NextSevenDaysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! CustomTableViewCell
        
        if indexPath.row <= 6 {
            cell.forecastDate.text = "\(self.NextSevenDaysData[indexPath.row].dt.fromUnixTimeToDate())"
//            cell.forecastSunriseTime.text = "Sunrise: " + self.NextSevenDaysData[indexPath.row].sunrise.fromUnixTimeToTime()
//            cell.forecastSunsetTime.text = "Sunset: " + self.NextSevenDaysData[indexPath.row].sunset.fromUnixTimeToTime()
//            cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
            let url = URL(string: "https://openweathermap.org/img/wn/" + self.NextSevenDaysData[indexPath.row].weather[0].icon + ".png")
            cell.forecastWeatherIcon.imageLoad(from: url!)
            cell.forecastWeatherDescription.text = "" + self.NextSevenDaysData[indexPath.row].weather[0].description.capitalized
            cell.forecastMaxTemp.text = "Max: \(self.NextSevenDaysData[indexPath.row].temp.max)°C"
            cell.forecastMinTemp.text = "Min: \(self.NextSevenDaysData[indexPath.row].temp.min)°C"
            
        }
        
        // Alter background color for even - odd row
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
