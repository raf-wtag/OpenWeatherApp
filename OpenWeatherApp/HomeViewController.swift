//
//  HomeViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController , CLLocationManagerDelegate, UICollectionViewDataSource {

    // MARK: Outlets
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
    
    // Variables to store lat and lon from "var currentLocation"
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
    
    // Timezone Identifier for calculating local time of any place
    var timezoneIdentifier = ""
    
    // User selected place's Location coordinate
    static var userSelectedPlacesLatitude: Double = 0
    static var userSelectedPlacesLongitude: Double = 0
    
    // To display the location Name
    static var userSelectedPlaceName = ""
    
    // Flag if user selects a location or not
    static var reloadWeatherDataStatusFlag = false
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add BackgroundImage in The HomeView
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpeg")!)
        
        // Load API Key from Key.json File -> "APIKEY_OPENWEATHERMAP" : "secretkey"
        if let apiData = self.readSecretKeyFile(forFileName: "Keys") {
            if let temp = self.parseSecretKeyFile(jsonData: apiData) {
                secretAPIKEY = temp
            }
        }

        // Access the device location and if successful then call API
        fetchCurrentLocation()
        
        // Define CollectionViewDataSource
        collection_View.dataSource = self
        
        // Obbserver to observe app comes foreground and apps goes to background Notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInBackgroundState), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInForegroundState), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    // MARK: ViewDidAppear()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If user selects a Place in SearchCityNameViewController
        if HomeViewController.reloadWeatherDataStatusFlag {
            // As user select a place so stop the previous timer
            timer.invalidate()
            print("In viewDidAppear", HomeViewController.userSelectedPlacesLongitude, HomeViewController.userSelectedPlacesLatitude)
            print("Lat: ", HomeViewController.userSelectedPlacesLatitude)
            print("Lon: ", HomeViewController.userSelectedPlacesLongitude)
//            sleep(30)
            
            // save the value to create the url of openweathermap api
            latitude = HomeViewController.userSelectedPlacesLatitude
            longitude = HomeViewController.userSelectedPlacesLongitude

            DispatchQueue.main.async {
                self.spinner.startAnimating()
            }
            
            // Call the FetchAPIData()
            callFetchAPIData()
        }
        
    }
    
    // MARK: GET OPENWEATHERMAP APIKEY From External File
    
    // Read the Keys.json file
    private func readSecretKeyFile(forFileName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print("ERROR in readSecretKeyFile()", error)
        }
        return nil
    }
    
    // Decode the Key from json
    private func parseSecretKeyFile(jsonData: Data) -> String? {
        do {
            let decodedSecretKeys = try JSONDecoder().decode(SecretKeysMap.self, from: jsonData)
            print("API key is", decodedSecretKeys.APIKEY_OPENWEATHERMAP)
            return decodedSecretKeys.APIKEY_OPENWEATHERMAP
        } catch {
            print("Error in parseSecretKeyFile()", error)
        }
        return nil
    }
    
    // MARK: - Location Part
    
    // Start Location fetch
    func fetchCurrentLocation() {
        // create CLLocationmanager object to fetch location
        locationManager = CLLocationManager()
        
        // Declare the delegates
        locationManager?.delegate = self
        
        // Ask user for location permission
        locationManager?.requestAlwaysAuthorization()
    }

    // For CLLocationManagerDelegate, we have to define 3 core methods
    // Check if User Permits Access or Not
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // User Permitted, Now Access Location
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
        // Check if user not permitted then Show a alert to guide
        else {
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
        
        if let lat = currentLocation?.coordinate.latitude {
            self.latitude = lat
            print("CLLocationManager - Latitude: ", self.latitude)
        }
        
        if let lon = currentLocation?.coordinate.longitude {
            self.longitude = lon
            print("CLLocationManager - Longitude: ", self.longitude)
        }

        // As now we have location now lets Call fetchAPIData()
        callFetchAPIData()
    }

    // Error Handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Check if error occured then present an alert to the user
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
    
    // MARK: - API Calling and Display
    
    // This will invoke fetchAPIData()
    private func callFetchAPIData() {
        fetchAPIData(completionHandler: { [self] (weather) in
            
            // Save data from response
            currentDayData = weather.current
            nextSevenDaysData = weather.daily
            hourlyData = weather.hourly
            timezoneIdentifier = weather.timezone
            
            // Change [daily] to display current and next seven days data
            modifyDailyDataFromAPIResponse()
            
            // Change [hourly] to display next 24 hours data
            modifyHourlyDataFromAPIResponse()
            
            // Now Dispatch all the data
            weatherForecastDataDisplay()
            
        })
    }
    
    // This function modidify the daily data from API response
    private func modifyDailyDataFromAPIResponse() {
        
        // If the daily reposne from API is not empty then stores the first items in that array as persentDayData and the rest 7 days forecast are stored in the nextSevendaysdata
        if !self.nextSevenDaysData.isEmpty {
            self.presentDayData = Array(self.nextSevenDaysData.prefix(1))
            self.nextSevenDaysData.removeFirst()
        }
        
    }
    
    // This function modidify hourly data from API response
    private func modifyHourlyDataFromAPIResponse() {
        
        // If the hourly data is not empty then store the first 24 hours from the API response
        if !self.hourlyData.isEmpty {
            print("Before Slicing", self.hourlyData.count)
            self.hourlyData = Array(self.hourlyData[0...23])
            print("After Slicing", self.hourlyData.count)
        }
        
    }
    
    // This function dispatch data in the HomeViewController After all data are ready
    private func weatherForecastDataDisplay() {
        
        // Now as we should have all data ready, its dispatch to the main queue to display data
        DispatchQueue.main.async {
            print("In Dispathch",self.currentDayData)
            
            // Dynamic time representation afetr fetching data from API
            self.dynamicCurrentDateNTime = self.currentDayData.dt
            self.getCurrentTime()
            
            // Other labels
//                self.presentDayDateNTime.text = self.CurrentDayData.dt.fromUnixTimeToTimeNDate()
            self.presentDayTemp.text = "\(self.currentDayData.temp)°"
            let url = URL(string: "https://openweathermap.org/img/wn/" + self.currentDayData.weather[0].icon + ".png")
            self.presentDayWeatherIcon.imageLoad(from: url!)
//                self.presentDayWeatherIcon.image = UIImage(named: self.CurrentDayData.weather[0].icon)
            self.presentDaySunriseTime.text = "Sunrise: " + self.currentDayData.sunrise.fromUnixTimeToTime()
            self.presentDaySunsetTime.text = "Sunset: " + self.currentDayData.sunset.fromUnixTimeToTime()
            self.presentDayFeels.text = "Feels like: \(self.currentDayData.feels_like)°C"
            self.presentdayWeatherDescription.text = self.currentDayData.weather[0].description.capitalized
            self.locationNameLabel.text = HomeViewController.userSelectedPlaceName
            
            // As we have data updated so we have to reload to display in the collectionview
            self.collection_View.reloadData()
            
            // All data are set to go so its time to stop the spinner
            self.spinner.stopAnimating()
            
        }
        
    }
    
    // MARK: Define fetchAPIData()
    
    //Define the fetchAPIData() with completionHandler to get data after data being loaded
    func fetchAPIData(completionHandler: @escaping (WeatherData) -> ()) {
        
        // Variables to construct api calling address
        let baseAddress = "https://api.openweathermap.org/data/2.5/onecall?"
        let lat = "lat=\(latitude)"
        let lon = "&lon=\(longitude)"
        let openWeatherMapAPIKEY = "&appid=" + secretAPIKEY
        let excludesFromAPIresponse = "&exclude=minutely,alerts"
        let unitsOfDataFromAPIResponse = "&units=metric"
        
        print("Latitude in fetchAPIData()", latitude)
        print("Longitude in fetchAPIData()", longitude)
        
        // construct url string
        let urlString = baseAddress + lat + lon + unitsOfDataFromAPIResponse + excludesFromAPIresponse + openWeatherMapAPIKEY
        
        print(urlString)
        
        // Checks if the url string contains valid characters or not
        guard let url = URL(string: urlString) else {
            print("Error In URL() in fetchAPIData()")
            return
        }
        
        // Fetch Data Definition
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            // Checks if the data successfully received or not
            guard let data = data, error == nil else {
                print("Error Occured in Retrieving Data in fetchAPIData()")
                return
            }
            
            // Prints Raw JSON response
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(jsonData)
            }
               
            // Decode the JSON and map it using codable protocol
            do {
                let result = try JSONDecoder().decode(WeatherData.self, from: data)
                completionHandler(result)
            } catch {
                print("Error in Data Decoding in fetchAPIData()", error)
            }
        })
        // Data fetching starts
        task.resume()

    }
    
    // MARK: CollectionView
    
    // Declare the delegate functions of collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionview_cell", for: indexPath) as! CustomCollectionViewCell
        print("\(self.hourlyData[indexPath.row].temp)°C")
        print(self.hourlyData[indexPath.row].dt.fromUnixTimeToTime())
        cell.forecastHourlyTemp.text = "\(self.hourlyData[indexPath.row].temp)°C"
        cell.forecastHourlyTime.text = self.hourlyData[indexPath.row].dt.fromUnixTimeToTime()
//        cell.forecastHourlyWeatherIcon.image = UIImage(named: self.HourlyData[indexPath.row].weather[0].icon)
        let urlString = "https://openweathermap.org/img/wn/" + self.hourlyData[indexPath.row].weather[0].icon + ".png"
        if let url = URL(string: urlString) {
            cell.forecastHourlyWeatherIcon.imageLoad(from: url)
        } else {
            print("Error in URL() in collectionView - cellForItemAt indexPath")
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.width, height: 180)
    }
    
    // MARK: Real Time Clock Display
    
    // Display real time
    func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.currentTimeAfterFetchedTime), userInfo: nil, repeats: true)
    }
    
    @objc func currentTimeAfterFetchedTime(currentTime : Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        let offset = TimeZone.current.secondsFromGMT()
//        print("Checking", offset)
        formatter.timeZone = TimeZone(identifier: self.timezoneIdentifier)
        
        DispatchQueue.main.async {
            self.presentDayDateNTime.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.dynamicCurrentDateNTime)))
            self.dynamicCurrentDateNTime += 1
            print(Date(timeIntervalSince1970: TimeInterval(self.dynamicCurrentDateNTime)))
        }
    }
    
    // MARK: Marker unwind segue destination
    @IBAction func unwindToHomeViewController(_ sender: UIStoryboardSegue) {}
    
    // MARK: Notification Observer Action
    // Observer Action for going to minimize state
    @objc func appWillEnterInBackgroundState() {
        print("About to go in background")
        timer.invalidate()
    }
    
    // Observer Action for coming back to foreground state
    @objc func appWillEnterInForegroundState() {
        print("In foreground")
        fetchCurrentLocation()
    }
    
    // MARK: Segue Part. From here we pass the data to the other view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as? WeeklyDataViewController
        
        if nextViewController != nil {
//            nextViewController?.latitude = self.latitude
//            nextViewController?.longitude = self.longitude
            nextViewController?.nextSevenDaysData = self.nextSevenDaysData
        }
    }
    
}
