//
//  HomeViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController , CLLocationManagerDelegate, UICollectionViewDataSource {

    // MARK: Outlets of this HomeViewController
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
    
    // MARK: Class Variables
    // Declare CLLocationmanager type variables to manage location data
    var locationManager: CLLocationManager?
    
    // Access uisng: currentLocation?.coordinate.latitude || currentLocation?.coordinate.longitude
    var currentLocation: CLLocation?
    
    // Variables to store lat and lon in class variable
    var latitude = 0.0
    var longitude = 0.0
    
    // variable to to read API key from Keys.json
    var secretAPIKEY = ""
    
    // NextSevenDaysData variable has 8 days reponse. But we discard today's data and stores next day's data
    var nextSevenDaysData = [Daily]()
    
    // Only present Day's Data
    var presentDayData = [Daily]()
    
    // Current Day's Info
    var currentDayData = Current(dt: 0, sunrise: 0, sunset: 0, temp: 0.0, feels_like: 0.0, weather: [])
    
    // Hourly data of 48 hours data fetched from API but stores only first 24 hours data
    var hourlyData = [Hourly]()
    
    // Timer object to create real time clock in the UI
    var timer = Timer()
    
    // Temporary variable to store and update the current time which is feteched from the API response
    var dynamicCurrentDateNTime = 0
    
    // MARK: viewControllerLifeCycle Method <ViewDidLoad>
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load API Key from Key.json File -> "APIKEY" : "secretkey"
        if let apiData = self.readSecretKeyFile(forFileName: "Keys") {
            if let temp = self.parseSecretKeyFile(jsonData: apiData) {
                secretAPIKEY = temp
            }
        }

        // Access the device location and if successful then call API
        fetchCurrentLocation()
        
        // Define CollectionViewDataSource
        collection_View.dataSource = self

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

    // MARK: - For CLLocationManagerDelegate, we have to define 3 core methods
    // Check if User Permits Access or Not
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // User Permitted, Now Access Location
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
        
        else {
            // MARK: Check if user not permitted then Show a alert to guide
            print("User Not Permitted", status)
            // Create new Alert
            let dialogMessage = UIAlertController(title: "Permission Not Given", message: "Please Go to Settings -> Privacy -> Location Services -> Click on OpenWeatherApp -> Allow Location Access (While using The App/Always)", preferredStyle: .alert)
            // Create a button to close Alert
            let okButtonOnAlert = UIAlertAction(title: "OK", style: .default, handler: {(action) -> () in
                print("Alert Ok Button Tapped")
            })
            // Add created ok button on the Alert
            dialogMessage.addAction(okButtonOnAlert)
            // Now Present the Alert to the user
            self.present(dialogMessage, animated: true, completion: nil)
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
        
        // MARK: API Calling
        // As now we have location now lets Call fetchAPIData() & Get Data from API Call
        fetchAPIData(completionHandler: {
            (current, weeklydata, hourlydata) in
            self.currentDayData = current
            self.nextSevenDaysData = weeklydata
            self.hourlyData = hourlydata
            
            print("After Fetching we got -> ", self.currentDayData)
            
            // If the daily reposne from API is not empty then stores the first items in that array
            // as persentDayData and the rest 7 days forecast are stored in the nextSevendaysdata
            if !self.nextSevenDaysData.isEmpty {
                self.presentDayData = Array(self.nextSevenDaysData.prefix(1))
//                print("Now printing", self.PresentDayData)
//                print("Again Printing", self.PresentDayData[0].weather[0].description)
                self.nextSevenDaysData.removeFirst()
            }
            
            // As API response gives 48 hours hourly data so we store only first 24 hours forecast data from that
            if !self.hourlyData.isEmpty {
                print("Before Slicing", self.hourlyData.count)
                self.hourlyData = Array(self.hourlyData[0...23])
                print("After Slicing", self.hourlyData.count)
            }
            
            // Now as we should have all data ready, its dispatch to the main queue to display data
            DispatchQueue.main.async {
                print("In Dispathch",self.currentDayData)
                
                // MARK: - Dynamic time representation afetr fetching data from API
                self.dynamicCurrentDateNTime = self.currentDayData.dt
                self.getCurrentTime()
                
                // MARK: Other labels
//                self.presentDayDateNTime.text = self.CurrentDayData.dt.fromUnixTimeToTimeNDate()
                self.presentDayTemp.text = "\(self.currentDayData.temp)°C"
                let url = URL(string: "https://openweathermap.org/img/wn/" + self.currentDayData.weather[0].icon + ".png")
                self.presentDayWeatherIcon.imageLoad(from: url!)
//                self.presentDayWeatherIcon.image = UIImage(named: self.CurrentDayData.weather[0].icon)
                self.presentDaySunriseTime.text = "Sunrise: " + self.currentDayData.sunrise.fromUnixTimeToTime()
                self.presentDaySunsetTime.text = "Sunset: " + self.currentDayData.sunset.fromUnixTimeToTime()
                self.presentDayFeels.text = "Feels like: \(self.currentDayData.feels_like)°C"
                self.presentdayWeatherDescription.text = self.currentDayData.weather[0].description.capitalized
                
                // As we have data updated so we have to reload to display in the collectionview
                self.collection_View.reloadData()
                
                // All data are set to go so its time to stop the spinner
                self.spinner.stopAnimating()
                // Change the background color of the viewcontroller
                self.view.backgroundColor = UIColor.white
            }
        })
        
//         Now Stop the Spinner
//        DispatchQueue.main.async {
//            self.spinner.stopAnimating()
//            self.view.backgroundColor = UIColor.white
//            print("In Dispathch",self.CurrentDayData)
//            self.presentDayDateNTime.text = self.CurrentDayData.dt.fromUnixTimeToTimeNDate()
//            self.presentDayTemp.text = "\(self.CurrentDayData.temp)"
//            self.presentDayWeatherIcon.image = UIImage(named: self.CurrentDayData.weather[0].icon)
//            self.presentDaySunriseTime.text = self.CurrentDayData.sunrise.fromUnixTimeToTime()
//            self.presentDaySunsetTime.text = self.CurrentDayData.sunset.fromUnixTimeToTime()
//            self.presentDayFeels.text = "\(self.CurrentDayData.feels_like)"
//            self.presentdayWeatherDescription.text = self.CurrentDayData.weather[0].description
//        }
    }
    
    // Error Handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // MARK: Check if error occured then present an alert to the user
        print(error)
        // Creates New alert
        let dialogMessage = UIAlertController(title: "Error in Fetching Location", message: "Error Occured: \(error). Please Turn Your Location On the Settings -> Privacy -> Location Services", preferredStyle: .alert)
        // Create a button for the alert cancel
        let okButtonInAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
        // Add created button to the alert
        dialogMessage.addAction(okButtonInAlert)
        // Present alert to the user
        self.present(dialogMessage, animated: true, completion: nil)
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
    //Define the fetchAPIData() with completionHandler to get data after data being loaded
    func fetchAPIData(completionHandler: @escaping (Current, [Daily], [Hourly]) -> ()) {
        
        // variables to return data to function caller
        var returnDailyData = [Daily]()
        var returnHourlyData = [Hourly]()
        
        // Variables to construct api calling address
        let baseAddress = "https://api.openweathermap.org/data/2.5/onecall?"
        let lat = "lat=\(latitude)"
        let lon = "&lon=\(longitude)"
        let openWeatherMapAPIKEY = "&appid=" + secretAPIKEY
        let excludesFromAPIresponse = "&exclude=minutely,alerts"
        let unitsOfDataFromAPIResponse = "&units=metric"
        
        print("I'm getting", latitude)
        print("I'm getting", longitude)
        
        let urlString = baseAddress + lat + lon + unitsOfDataFromAPIResponse + excludesFromAPIresponse + openWeatherMapAPIKEY
        
//        let urlString = address + lat + "&lon=" + lon + "&units=metric&exclude=minutely,alerts&appid=" + APIKEY
        
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
            
            // If all Okey then return data by using completion Handler
            if let res = result {
                returnDailyData = res.daily
                returnCurrentData = res.current
                returnHourlyData = res.hourly
            }
            
            completionHandler(returnCurrentData, returnDailyData, returnHourlyData)
        })
        task.resume()
        
//        completionHandler(returnDailyData, returnDailyData, returnHourlyData)
    }
    
    // Mark: Segue Part. From here we pass the data to the other view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as? WeeklyDataViewController
        
        if nextViewController != nil {
//            nextViewController?.latitude = self.latitude
//            nextViewController?.longitude = self.longitude
            nextViewController?.nextSevenDaysData = self.nextSevenDaysData
        }
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyData.count
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionview_cell", for: indexPath) as! CustomCollectionViewCell
        print("\(self.hourlyData[indexPath.row].temp)°C")
        print(self.hourlyData[indexPath.row].dt.fromUnixTimeToTime())
        cell.forecastHourlyTemp.text = "\(self.hourlyData[indexPath.row].temp)°C"
        cell.forecastHourlyTime.text = self.hourlyData[indexPath.row].dt.fromUnixTimeToTime()
//        cell.forecastHourlyWeatherIcon.image = UIImage(named: self.HourlyData[indexPath.row].weather[0].icon)
        let url = URL(string: "https://openweathermap.org/img/wn/" + self.hourlyData[indexPath.row].weather[0].icon + ".png")
        cell.forecastHourlyWeatherIcon.imageLoad(from: url!)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.width, height: 200)
    }
    
    // MARK: - Real Time Clock Display
    func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.currentTimeAfterFetchedTime), userInfo: nil, repeats: true)
    }
    
    @objc func currentTimeAfterFetchedTime(currentTime : Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.timeZone = TimeZone.current
        DispatchQueue.main.async {
            self.presentDayDateNTime.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.dynamicCurrentDateNTime)))
            self.dynamicCurrentDateNTime += 1
            print(Date(timeIntervalSince1970: TimeInterval(self.dynamicCurrentDateNTime)))
        }
    }
    
}
