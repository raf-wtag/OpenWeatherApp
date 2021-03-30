//
//  WeeklyDataViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit

class WeeklyDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var customTableLable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var DailyData = [Daily]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var latitude = 0.0
    var longitude = 0.0
    var secretAPIKEY = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load API Key from SecretKey.json File -> "APIKEY" : "secretkey"
        if let apiData = self.readSecretKeyFile(forFileName: "Keys") {
            if let temp = self.parseSecretKeyFile(jsonData: apiData) {
                secretAPIKEY = temp
            }
        }
        
        // Call & Get Data from API Call
        fetchAPIData(completionHandler: {
            data in
            self.DailyData = data
            
            if !self.DailyData.isEmpty {
                self.DailyData.removeFirst()
            }
        })
        
        // Declare the dataSource and Delegates
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: GET APIKEY From External File
    // Read the .json file
    private func readSecretKeyFile(forFileName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print("API KEY LOADING FAILED WITH ERROR", error)
        }
        return nil
    }
    
    // Decode the Key from json
    private func parseSecretKeyFile(jsonData: Data) -> String? {
        do {
            let decodedSecretKeys = try JSONDecoder().decode(SecretKeysMap.self, from: jsonData)
            print("API key is", decodedSecretKeys.APIKEY)
            return decodedSecretKeys.APIKEY
        } catch {
            print("Hey!! Error in Decoding!!")
        }
        return nil
    }
    
    // MARK: Call & Fetch the API Data
    func fetchAPIData(completionHandler: @escaping ([Daily]) -> Void) {
        
        var returnDailyData = [Daily]()
        
        let address = "https://api.openweathermap.org/data/2.5/onecall?lat="
        let lat = "\(latitude)"
        let lon = "\(longitude)"
//        let APIKEY = "a32d1247d69743e1f60a87f3a5a904c8"
        let APIKEY = secretAPIKEY
        
        print("I'm getting", latitude)
        print("I'm getting", longitude)
        
        let urlString = address + lat + "&lon=" + lon + "&units=metric&exclude=current,minutely,hourly,alerts&appid=" + APIKEY
        
        print(urlString)
//        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=23.8103&lon=90.4125&units=metric&exclude=current,minutely,hourly,alerts&appid=a32d1247d69743e1f60a87f3a5a904c8"

        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
           
            guard let data = data, error == nil else {
                print("Error Occured")
                return
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(jsonData)
            }
                    
            let result = try? JSONDecoder().decode(WeatherData.self, from: data)
            
            if let res = result {
                returnDailyData = res.daily
            }
            
            completionHandler(returnDailyData)
        })
        task.resume()
        
        completionHandler(returnDailyData)
    }
    
    // Core Methods of TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DailyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! CustomTableViewCell
        
        if indexPath.row <= 6 {
            cell.forecastDate.text = "\(self.DailyData[indexPath.row].dt.fromUnixTimeStamp())"
            cell.forecastMaxTemp.text = "Max: \(self.DailyData[indexPath.row].temp.max)°C"
            cell.forecastMinTemp.text = "Min: \(self.DailyData[indexPath.row].temp.min)°C"
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
}

extension Int {

    func  fromUnixTimeStamp() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        if let retData = dateFormatter.string(for: date) {
            return retData
        }
        return ""
    }
}
