//
//  HomeViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var presentDayDateNTime: UILabel!
    @IBOutlet weak var presentDayTemp: UILabel!
    @IBOutlet weak var presentDayWeatherIcon: UIImageView!
    @IBOutlet weak var presentDaySunriseTime: UILabel!
    @IBOutlet weak var presentDaySunsetTime: UILabel!
    @IBOutlet weak var presentDayFeels: UILabel!
    @IBOutlet weak var presentdayWeatherDescription: UILabel!
    @IBOutlet weak var weekForecastButton: UIButton!
    @IBOutlet weak var collection_View: UICollectionView!
    
    // Declare CLLocationmanager type variables to manage location data
    var locationManager: CLLocationManager?
    
    // Access uisng: currentLocation?.coordinate.latitude || currentLocation?.coordinate.longitude
    var currentLocation: CLLocation?
    
    var latitude = 0.0
    var longitude = 0.0
    
    var secretAPIKEY = ""
    var NextSevenDaysData = [Daily]()
    var PresentDayData = [Daily]()
    var CurrentDayData = Current(dt: 0, sunrise: 0, sunset: 0, temp: 0.0, feels_like: 0.0, weather: [])
    var HourlyData = [Hourly]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load API Key from SecretKey.json File -> "APIKEY" : "secretkey"
        if let apiData = self.readSecretKeyFile(forFileName: "Keys") {
            if let temp = self.parseSecretKeyFile(jsonData: apiData) {
                secretAPIKEY = temp
            }
        }

        // Access the device location and if successful then call API
        fetchCurrentLocation()
        
        // Define CollectionViewDataSource
//        collection_View.dataSource = self
//        collection_View.delegate = self

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // Again Check for location permission and similar stuffs
//        fetchCurrentLocation()
//
//    }
    
    // MARK: - Location Part
    func fetchCurrentLocation() {
        // create CLLocationmanager object to fetch location
        locationManager = CLLocationManager()
        
        // Declare the delegates
        locationManager?.delegate = self
        
        // Ask user for location permission
        locationManager?.requestAlwaysAuthorization()
    }

    // MARK: - For Delegate we have to declare 3 core methods
    
    // Check if User Permits Access or Not
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // User Permitted, Now Access Location
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
        
        else {
            // TODO: Check if user not permitted then what happens!!
            print("User Not Permitted", status)
        }
    }
    
    // Access Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // save the last accessed location
        currentLocation = locations.last
        print("lat: \(currentLocation?.coordinate.latitude) - lon: \(currentLocation?.coordinate.longitude)")
        
        if let lat = currentLocation?.coordinate.latitude {
            self.latitude = lat
            print("Now Saving", self.latitude)
        }
        
        if let lon = currentLocation?.coordinate.longitude {
            self.longitude = lon
            print("Now Saving", self.longitude)
        }
        
        // MARK: API Calling Start
        // As now we have location now lets Call & Get Data from API Call
        fetchAPIData(completionHandler: {
            (current, weeklydata, hourlydata) in
            self.CurrentDayData = current
            self.NextSevenDaysData = weeklydata
            self.HourlyData = hourlydata
            
            print("After Fetching we got -> ", self.CurrentDayData)
            
            if !self.NextSevenDaysData.isEmpty {
                self.PresentDayData = Array(self.NextSevenDaysData.prefix(1))
//                print("Now printing", self.PresentDayData)
//                print("Again Printing", self.PresentDayData[0].weather[0].description)
                self.NextSevenDaysData.removeFirst()
            }
            
            DispatchQueue.main.async {
                print("In Dispathch",self.CurrentDayData)
                self.presentDayDateNTime.text = self.CurrentDayData.dt.fromUnixTimeToTimeNDate()
                self.presentDayTemp.text = "\(self.CurrentDayData.temp)°C"
                let url = URL(string: "https://openweathermap.org/img/wn/" + self.CurrentDayData.weather[0].icon + ".png")
                self.presentDayWeatherIcon.imageLoad(from: url!)
//                self.presentDayWeatherIcon.image = UIImage(named: self.CurrentDayData.weather[0].icon)
                self.presentDaySunriseTime.text = "Sunrise: " + self.CurrentDayData.sunrise.fromUnixTimeToTime()
                self.presentDaySunsetTime.text = "Sunset: " + self.CurrentDayData.sunset.fromUnixTimeToTime()
                self.presentDayFeels.text = "Feels like: \(self.CurrentDayData.feels_like)°C"
                self.presentdayWeatherDescription.text = self.CurrentDayData.weather[0].description.capitalized
                
                self.collection_View.reloadData()
            }
        })
        
        // Now Stop the Spinner
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
//            print("In Dispathch",self.CurrentDayData)
//            self.presentDayDateNTime.text = self.CurrentDayData.dt.fromUnixTimeToTimeNDate()
//            self.presentDayTemp.text = "\(self.CurrentDayData.temp)"
//            self.presentDayWeatherIcon.image = UIImage(named: self.CurrentDayData.weather[0].icon)
//            self.presentDaySunriseTime.text = self.CurrentDayData.sunrise.fromUnixTimeToTime()
//            self.presentDaySunsetTime.text = self.CurrentDayData.sunset.fromUnixTimeToTime()
//            self.presentDayFeels.text = "\(self.CurrentDayData.feels_like)"
//            self.presentdayWeatherDescription.text = self.CurrentDayData.weather[0].description
        }
    }
    
    // Error Handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Check if error occured then what happens!!
        print(error)
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
    func fetchAPIData(completionHandler: @escaping (Current, [Daily], [Hourly]) -> ()) {
        
        var returnDailyData = [Daily]()
        var returnHourlyData = [Hourly]()
        
        let address = "https://api.openweathermap.org/data/2.5/onecall?lat="
        let lat = "\(latitude)"
        let lon = "\(longitude)"
//        let APIKEY = "a32d1247d69743e1f60a87f3a5a904c8"
        let APIKEY = secretAPIKEY
        
        print("I'm getting", latitude)
        print("I'm getting", longitude)
        
        let urlString = address + lat + "&lon=" + lon + "&units=metric&exclude=minutely,alerts&appid=" + APIKEY
        
        print(urlString)
//        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=23.8103&lon=90.4125&units=metric&exclude=current,minutely,hourly,alerts&appid=a32d1247d69743e1f60a87f3a5a904c8"

        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
           
            var returnCurrentData = Current(dt: 0, sunrise: 0, sunset: 0, temp: 0.0, feels_like: 0.0, weather: [])
            
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
                returnCurrentData = res.current
                returnHourlyData = res.hourly
            }
            
            completionHandler(returnCurrentData, returnDailyData, returnHourlyData)
        })
        task.resume()
        
//        completionHandler(returnDailyData, retu)
    }
    
    // Mark: Segue Part. From here we pass the data to the other view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as? WeeklyDataViewController
        
        if nextViewController != nil {
//            nextViewController?.latitude = self.latitude
//            nextViewController?.longitude = self.longitude
            nextViewController?.NextSevenDaysData = self.NextSevenDaysData
        }
    }
    
    // MARK: CollectionView
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return HourlyData.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionview_cell", for: indexPath) as! CustomCollectionViewCell
//        print("\(self.HourlyData[indexPath.row].temp)°C")
//        print(self.HourlyData[indexPath.row].dt.fromUnixTimeToTime())
//        cell.forecastHourlyTemp.text = "\(self.HourlyData[indexPath.row].temp)°C"
//        cell.forecastHourlyTime.text = self.HourlyData[indexPath.row].dt.fromUnixTimeToTime()
//        cell.forecastHourlyWeatherIcon.image = UIImage(named: self.HourlyData[indexPath.row].weather[0].icon)
//
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//            return CGSize(width: view.frame.width, height: 200)
//    }
    
}
