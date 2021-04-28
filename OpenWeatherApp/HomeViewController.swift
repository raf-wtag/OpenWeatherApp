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
    @IBOutlet weak var collection_View: UICollectionView!
    
    // MARK: Class Variables
    
    // create CLLocationmanager object to manage location data
    var locationManager = CLLocationManager()
    
    // Access uisng: currentLocation?.coordinate.latitude || currentLocation?.coordinate.longitude
    var currentLocation: CLLocation?
    
    // Variables to store lat and lon from "var currentLocation"
    var latitude = 0.0
    var longitude = 0.0
    
    // variable to to read API key from Keys.json
    var openWeatherMap_access_token = ""
    
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
    
    // To display the location Name
    var locationName = ""
    
    let dateFormatter = DateFormatter()
    var isAppEverWentInBackgroundState = false
    var timeWhenAppWentInBackground = ""
    var timeWhenAppComeInForeground = ""
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add BackgroundImage in The HomeView
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpeg")!)
        
        // Load API Key from Key.json File -> "APIKEY_OPENWEATHERMAP" : "secretkey"
        let fileReader = FileReader()
        if let apiData = fileReader.readSecretKeyFile(forFileName: "Keys") {
            if let tempData = fileReader.parseSecretKeyFile(jsonData: apiData, keyFor: "openweathermap") {
                openWeatherMap_access_token = tempData
            }
        }
        
        if let userSearchedLocationName = UserDefaults.standard.string(forKey: "userSelectedPlacesnameValue") {
            retriveSavedLocationData(for: userSearchedLocationName)
        } else {
            checkLocationServies()
        }

        // Access the device location and if successful then call API
//        fetchCurrentLocation()
//        checkLocationServies()
        
        // As now we have location now lets Call fetchAPIData()
        callFetchAPIData()
        
        // Define CollectionViewDataSource
        collection_View.dataSource = self
        print("Am I printing?")
        // Obbserver to observe app comes foreground and apps goes to background Notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInBackgroundState), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInForegroundState), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    private func retriveSavedLocationData(for place: String) {
        locationName = place
        latitude = UserDefaults.standard.double(forKey: "userSelectedPlacesLatitudeValue")
        longitude = UserDefaults.standard.double(forKey: "userSelectedPlacesLongitudeValue")
    }
    
    // MARK: - Location Part
    
    // Check the current status of the Location Service of the device
    func checkLocationServies() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Alart to tell user to turn on the location service
            displayAlertWithButton(dialogTitle: "Turn on Location Services", dialogMessage: "Please Turn \"Location Services\" On From \"Settings -> Privacy -> Location Services -> Location Sevices\".", buttonTitle: "Close")
        }
    }
    
    // setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // check what permission user give to this application
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .denied:
            // Show alart to how to trun on permission
            displayAlertWithButton(dialogTitle: "Turn on Location Access For this App", dialogMessage: "Please Turn \"Location Access Permission\" On From \"Settings -> Privacy -> Location Services -> OpenWeatherApp -> While Using the App\".", buttonTitle: "OK")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
           displayAlertWithButton(dialogTitle: "Restricted By User", dialogMessage: "This is possibly due to active restrictions such as parental controls being in place.", buttonTitle: "Close")
        case .authorizedAlways:
            // If user changes the authorization via Settings -> Privacy -> Location Services -> OpenWeatherApp -> While Using the App
            locationManager.requestLocation()
        default:
            print("Somting Wrong in checkLocationAuthorization()")
        }
    }

    // CLLocationManagerDelegate, we have to define 3 core methods
    // Everytime Authorization status changes this is being called
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
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

        // Now call reverseGeocodeLocation
        callReverseGeoCoder()
        
    }
    
    // Error Handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Check if error occured then present an alert to the user
        print(error)
        displayAlertWithButton(dialogTitle: "Error in Fetching Location", dialogMessage: "Error Occured: \(error). Please Check Your Location On the Settings -> Privacy -> Location Services", buttonTitle: "Close")
    }
    
    // Alert creater function to show alert to the user
    func displayAlertWithButton(dialogTitle title: String, dialogMessage message: String, buttonTitle name: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButtonInAlert = UIAlertAction(title: name, style: .default, handler: nil)
        dialogMessage.addAction(okButtonInAlert)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    // This  will use reverseGeocodeLocation to determine the name of the place
    private func callReverseGeoCoder() {
        let geoCoder = CLGeocoder()
        let userCurrentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude     )
        geoCoder.reverseGeocodeLocation(userCurrentLocation, completionHandler: { (placemarks, error) in
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            if let placeName = placemark.locality, let placeCountry =  placemark.country {
                print(placeName)
                self.locationName = "\(placeName), \(placeCountry)"
            } else {
                print("Error in callReverseGeoCoder()")
            }
            
            
        })
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
            self.locationNameLabel.text = self.locationName
            
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
        let openWeatherMapAPIKEY = "&appid=" + openWeatherMap_access_token
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
        timer.invalidate()
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
    
    @IBAction func unwindToHomeViewController(_ sender: UIStoryboardSegue) {
        guard let userSearchedLocationName = UserDefaults.standard.string(forKey: "userSelectedPlacesnameValue") else {
            print("Error in retriving data from userDefaults")
            return
        }
        
        retriveSavedLocationData(for: userSearchedLocationName)
        
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }

        // Call the FetchAPIData()
        callFetchAPIData()
        
//        if let sourceVC = sender.source as? SearchCityNameViewController {
//            // store data in the variables
//            locationName = sourceVC.userSelectedPlacesname
//            latitude = sourceVC.userSelectedPlacesLatitude
//            longitude = sourceVC.userSelectedPlacesLongitude
//
//            DispatchQueue.main.async {
//                self.spinner.startAnimating()
//            }
//
//            // Call the FetchAPIData()
//            timer.invalidate()
//            callFetchAPIData()
//        }
    }
    
    // MARK: Notification Observer Action
    
    // Observer Action for going to minimize state
    @objc func appWillEnterInBackgroundState() {
        print("About to go in background")
        isAppEverWentInBackgroundState = true
        dateFormatter.dateFormat = "h:mm:ss"
        timeWhenAppWentInBackground = dateFormatter.string(from: Date())
        print("Time now -> \(timeWhenAppWentInBackground)")
//        timer.invalidate()
    }
    
    // Observer Action for coming back to foreground state
    @objc func appWillEnterInForegroundState() {
        print("In foreground")
//        fetchCurrentLocation()
//        timer.invalidate()
//        checkLocationServies()
        
        dateFormatter.dateFormat = "h:mm:ss"
        timeWhenAppComeInForeground = dateFormatter.string(from: Date())
        
        if let timeSpent = checkHowMuchTimeAppWasInBackground(), timeSpent >= 1.0 {
            checkLocationServies()
        }
    }
    
    private func checkHowMuchTimeAppWasInBackground() -> Double? {
        if isAppEverWentInBackgroundState {
            guard let timeAtBackground = dateFormatter.date(from: timeWhenAppWentInBackground),
                  let timeAtForeground = dateFormatter.date(from: timeWhenAppComeInForeground) else {
                print("Error in time -> isAppEverWentInBackgroundState check")
                return nil
            }
            let interval = timeAtForeground.timeIntervalSince(timeAtBackground)
            let minute = interval / 60
            print("after \(minute)")
            return minute
        }
        return nil
    }
    
    // MARK: Segue Part. From here we pass the data to the WeeklyDataViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as? WeeklyDataViewController
        
        if nextViewController != nil {
//            nextViewController?.latitude = self.latitude
//            nextViewController?.longitude = self.longitude
            nextViewController?.nextSevenDaysData = self.nextSevenDaysData
        }
    }
    
}
