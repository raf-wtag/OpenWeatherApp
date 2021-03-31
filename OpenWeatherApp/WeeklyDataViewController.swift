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
            cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
            cell.forecastWeatherDescription.text = "" + self.NextSevenDaysData[indexPath.row].weather[0].description.capitalized
            cell.forecastMaxTemp.text = "\(self.NextSevenDaysData[indexPath.row].temp.max)°C"
            cell.forecastMinTemp.text = "\(self.NextSevenDaysData[indexPath.row].temp.min)°C"
            
        }
        
        // Alter background color for even - odd row
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension Int {

    func  fromUnixTimeToDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    func  fromUnixTimeToTime() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    func  fromUnixTimeToTimeNDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
    
    
}
