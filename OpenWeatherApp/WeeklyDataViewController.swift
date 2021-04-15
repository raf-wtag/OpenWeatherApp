//
//  WeeklyDataViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit

class WeeklyDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Class variables
//    var latitude = 0.0
//    var longitude = 0.0
    
    // list to show next seven days forecast
    var nextSevenDaysData = [Daily]()
    
    // Icon for tableview cell
    var iconImage: UIImage? = nil
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Declare the dataSource and Delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        // Add Background Image In the tableView
        tableView.backgroundView = UIImageView(image: UIImage(named: "background.jpeg"))
        
    }
    
    
    // MARK: TableView Part
    
    // Core Methods of TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nextSevenDaysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! CustomTableViewCell
        
        if indexPath.row <= 6 {
            cell.forecastDate.text = "\(self.nextSevenDaysData[indexPath.row].dt.fromUnixTimeToDate())"
//            cell.forecastSunriseTime.text = "Sunrise: " + self.NextSevenDaysData[indexPath.row].sunrise.fromUnixTimeToTime()
//            cell.forecastSunsetTime.text = "Sunset: " + self.NextSevenDaysData[indexPath.row].sunset.fromUnixTimeToTime()
//            cell.forecastWeatherIcon.image = UIImage(named: self.NextSevenDaysData[indexPath.row].weather[0].icon)
            let url = URL(string: "https://openweathermap.org/img/wn/" + self.nextSevenDaysData[indexPath.row].weather[0].icon + ".png")
            cell.forecastWeatherIcon.imageLoad(from: url!)
            cell.forecastWeatherDescription.text = "" + self.nextSevenDaysData[indexPath.row].weather[0].description.capitalized
            cell.forecastMaxTemp.text = "Max: \(self.nextSevenDaysData[indexPath.row].temp.max)°C"
            cell.forecastMinTemp.text = "Min: \(self.nextSevenDaysData[indexPath.row].temp.min)°C"
            
        }
        
        // Alter background color for even - odd row
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .cyan : .lightGray
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
