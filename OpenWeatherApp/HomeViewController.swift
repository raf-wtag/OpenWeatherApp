//
//  HomeViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import CoreLocation
import RealmSwift

class HomeViewController: UIViewController {

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
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var latitude = 0.0
    var longitude = 0.0
    var openWeatherMap_access_token = ""
    var nextSevenDaysData = [Daily]()
    var presentDayData = [Daily]()
    var currentDayData = Current(dt: 0, sunrise: 0, sunset: 0, temp: 0.0, feels_like: 0.0, weather: [])
    var hourlyData = [Hourly]()
    var timer = Timer()
    var dynamicCurrentDateNTime = 0
    var timezoneIdentifier = ""
    var locationName = ""
    let dateFormatter = DateFormatter()
    var isAppEverWentInBackgroundState = false
    var timeWhenAppWentInBackground = ""
    var timeWhenAppComeInForeground = ""
    
    // MARK:- viewDidLoad() Part
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpeg")!)
        
        let fileReader = FileReader()
        if let apiData = fileReader.readSecretKeyFile(forFileName: "Keys") {
            if let tempData = fileReader.parseSecretKeyFile(jsonData: apiData, keyFor: "openweathermap") {
                openWeatherMap_access_token = tempData
            }
        }
        
//        if let userSearchedLocationName = UserDefaults.standard.string(forKey: "userSelectedPlacesnameValue") {
//            retriveSavedLocationData(for: userSearchedLocationName)
//        } else {
//            checkLocationServies()
//        }
        
        if checkIfDataStoredInRealm() {
            retriveSavedLocationDataFromRealm()
        } else {
            checkLocationServies()
        }

        callFetchAPIData()
        
        collection_View.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInBackgroundState), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterInForegroundState), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
//    private func retriveSavedLocationData(for place: String) {
//        locationName = place
//        latitude = UserDefaults.standard.double(forKey: "userSelectedPlacesLatitudeValue")
//        longitude = UserDefaults.standard.double(forKey: "userSelectedPlacesLongitudeValue")
//    }
    
    private func checkIfDataStoredInRealm() -> Bool {
        do {
            let realmReference = try Realm()
            let fetchedDataFromRealm = realmReference.objects(StoredWeatherInfos.self)
            
            if fetchedDataFromRealm.count > 0 {
                return true
            }
        } catch {
            print("Error in Realm Integration in HomeViewController()")
        }
        return false
    }
    
    private func retriveSavedLocationDataFromRealm() {
        do {
            let realmReference = try Realm()
            let fetchedDataFromRealm = realmReference.objects(StoredWeatherInfos.self)
            
            if fetchedDataFromRealm.count == 1 {
                locationName = fetchedDataFromRealm[0].stored_cityName
                latitude = fetchedDataFromRealm[0].stored_latitude
                longitude = fetchedDataFromRealm[0].stored_longitude
            }
        } catch {
            print("Error in Realm Integration in HomeViewController()")
        }
    }

    // MARK: - API Calling and Display
    private func callFetchAPIData() {
        fetchAPIData(completionHandler: { [self] (weather) in

            currentDayData = weather.current
            nextSevenDaysData = weather.daily
            hourlyData = weather.hourly
            timezoneIdentifier = weather.timezone

            modifyDailyDataFromAPIResponse()
            modifyHourlyDataFromAPIResponse()
            weatherForecastDataDisplay()
        })
    }

    private func modifyDailyDataFromAPIResponse() {
        if !self.nextSevenDaysData.isEmpty {
            self.presentDayData = Array(self.nextSevenDaysData.prefix(1))
            self.nextSevenDaysData.removeFirst()
        }
    }
    
    private func modifyHourlyDataFromAPIResponse() {
        if !self.hourlyData.isEmpty {
            print("Before Slicing", self.hourlyData.count)
            self.hourlyData = Array(self.hourlyData[0...23])
            print("After Slicing", self.hourlyData.count)
        }
    }

    private func weatherForecastDataDisplay() {
        DispatchQueue.main.async {
            print("In Dispathch",self.currentDayData)
            self.dynamicCurrentDateNTime = self.currentDayData.dt
            self.getCurrentTime()
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
            
            self.collection_View.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    // MARK:- Real Time Clock Display
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
    
    // MARK:- Notification Observer Action
    @objc func appWillEnterInBackgroundState() {
        print("About to go in background")
        isAppEverWentInBackgroundState = true
        dateFormatter.dateFormat = "h:mm:ss"
        timeWhenAppWentInBackground = dateFormatter.string(from: Date())
        print("Time now -> \(timeWhenAppWentInBackground)")
//        timer.invalidate()
    }

    @objc func appWillEnterInForegroundState() {
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
}


// MARK:- Location Feteching Part
extension HomeViewController: CLLocationManagerDelegate {
    func checkLocationServies() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            displayAlertWithButton(dialogTitle: "Turn on Location Services", dialogMessage: "Please Turn \"Location Services\" On From \"Settings -> Privacy -> Location Services -> Location Sevices\".", buttonTitle: "Close")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .denied:
            displayAlertWithButton(dialogTitle: "Turn on Location Access For this App", dialogMessage: "Please Turn \"Location Access Permission\" On From \"Settings -> Privacy -> Location Services -> OpenWeatherApp -> While Using the App\".", buttonTitle: "Okay")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
           displayAlertWithButton(dialogTitle: "Restricted By User", dialogMessage: "This is possibly due to active restrictions such as parental controls being in place.", buttonTitle: "Close")
        case .authorizedAlways:
            locationManager.requestLocation()
        default:
           displayAlertWithButton(dialogTitle: "Unknown Case!", dialogMessage: "This Permission is not handled in developing time.", buttonTitle: "Okay")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        if let lat = currentLocation?.coordinate.latitude {
            self.latitude = lat
            print("CLLocationManager - Latitude: ", self.latitude)
        }
        
        if let lon = currentLocation?.coordinate.longitude {
            self.longitude = lon
            print("CLLocationManager - Longitude: ", self.longitude)
        }

        callReverseGeoCoder()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        displayAlertWithButton(dialogTitle: "Error in Fetching Location", dialogMessage: "Error Occured: \(error). Please Check Your Location On the Settings -> Privacy -> Location Services", buttonTitle: "Close")
    }

    func displayAlertWithButton(dialogTitle title: String, dialogMessage message: String, buttonTitle name: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButtonInAlert = UIAlertAction(title: name, style: .default, handler: nil)
        dialogMessage.addAction(okButtonInAlert)
        self.present(dialogMessage, animated: true, completion: nil)
    }

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
}

// MARK:- Define fetchAPIData()
extension HomeViewController {
    func fetchAPIData(completionHandler: @escaping (WeatherData) -> ()) {
        let baseAddress = "https://api.openweathermap.org/data/2.5/onecall?"
        let lat = "lat=\(latitude)"
        let lon = "&lon=\(longitude)"
        let openWeatherMapAPIKEY = "&appid=" + openWeatherMap_access_token
        let excludesFromAPIresponse = "&exclude=minutely,alerts"
        let unitsOfDataFromAPIResponse = "&units=metric"
        
        print("Latitude in fetchAPIData()", latitude)
        print("Longitude in fetchAPIData()", longitude)
        
        let urlString = baseAddress + lat + lon + unitsOfDataFromAPIResponse + excludesFromAPIresponse + openWeatherMapAPIKEY
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            print("Error In URL construction in fetchAPIData()")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error Occured in Retrieving Data in fetchAPIData()")
                return
            }
            
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(jsonData)
            }
            
            do {
                let result = try JSONDecoder().decode(WeatherData.self, from: data)
                completionHandler(result)
            } catch {
                print("Error in Data Decoding in fetchAPIData()", error)
            }
        }
        task.resume()
    }
}

// MARK:- CollectionView
extension HomeViewController: UICollectionViewDataSource {
    
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
}

// MARK:- Segue
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as? WeeklyDataViewController
        
        if nextViewController != nil {
//            nextViewController?.latitude = self.latitude
//            nextViewController?.longitude = self.longitude
            nextViewController?.nextSevenDaysData = self.nextSevenDaysData

            do {
                let realmReference = try Realm()
                print("@@@@@@@@@@@@@@@@@@@@@")
                realmReference.beginWrite()
                realmReference.delete(realmReference.objects(StoredDailyWeatherForecasts.self))
                realmReference.delete(realmReference.objects(TemperatureResponse.self))
                realmReference.delete(realmReference.objects(WeatherResponse.self))
                try realmReference.commitWrite()
                
                for eachItem in nextSevenDaysData {
                    let weatherList = List<WeatherResponse>()
                    let saveWeather = WeatherResponse()
                    saveWeather.weather_description = eachItem.weather.first?.description ?? ""
                    saveWeather.weather_icon = eachItem.weather.first?.icon ?? ""
                    weatherList.append(saveWeather)
                    
                    let saveTemperature = TemperatureResponse()
                    saveTemperature.max_temperature = eachItem.temp.max
                    saveTemperature.min_temperature = eachItem.temp.min
                    
                    let saveDailyWeatherForecast = StoredDailyWeatherForecasts()
                    saveDailyWeatherForecast.date_time = eachItem.dt
                    saveDailyWeatherForecast.temperatures = saveTemperature
                    saveDailyWeatherForecast.weather = weatherList

                    realmReference.beginWrite()
                    realmReference.add(saveDailyWeatherForecast)
                    try realmReference.commitWrite()
                }

                print("@@@@@@@@@@@@@@@@@@@@@@@")
            } catch {
                print("Error in saving NextSevendaysData")
            }
        }
    }
    
    @IBAction func unwindToHomeViewController(_ sender: UIStoryboardSegue) {
//        guard let userSearchedLocationName = UserDefaults.standard.string(forKey: "userSelectedPlacesnameValue") else {
//            print("Error in retriving data from userDefaults")
//            return
//        }
        
//        retriveSavedLocationData(for: userSearchedLocationName)
        retriveSavedLocationDataFromRealm()
        
        
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
        
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
}
