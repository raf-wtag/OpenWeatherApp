//
//  HomeViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var presentDayForecast: UILabel!
    @IBOutlet weak var weekForecastButton: UIButton!
    
    // Declare CLLocationmanager type variables to manage location data
    var locationManager: CLLocationManager?
    
    // Access uisng: currentLocation?.coordinate.latitude || currentLocation?.coordinate.longitude
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Access the device location
        fetchCurrentLocation()
       
    }
    
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
        
        // Now Stop the Spinner
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    // Error Handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Check if error occured then what happens!!
        print(error)
    }

}
