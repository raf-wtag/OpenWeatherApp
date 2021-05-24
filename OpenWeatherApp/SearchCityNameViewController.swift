//
//  SearchCityNameViewController.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 11/4/21.
//

import UIKit
import RealmSwift

class SearchCityNameViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var isSearchActive = false
    var mapbox_api = "https://api.mapbox.com/geocoding/v5/mapbox.places/"
    var mapbox_access_token = ""
    var secretKeyContainFile = "Keys"
    var suggestedPlacenames = [Feature]()
    var userSelectedPlacesLatitude: Double = 0
    var userSelectedPlacesLongitude: Double = 0
    var userSelectedPlacesname = ""
    
    // MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        let fileReader = FileReader()
        if let apiData = fileReader.readSecretKeyFile(forFileName: "Keys") {
            if let tempData = fileReader.parseSecretKeyFile(jsonData: apiData, keyFor: "mapBox") {
                mapbox_access_token = tempData
            }
        }

        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK:- SearchBar Delegate Functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearching()
        self.isSearchActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchPlacesSuggestion), object: nil)
        
        self.perform(#selector(self.searchPlacesSuggestion), with:nil, afterDelay: 0.5)
        
        if((searchBar.text?.isEmpty) != nil) {
            isSearchActive = false
        } else {
            isSearchActive = true
        }
    }
    
    func cancelSearching() {
        isSearchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        suggestedPlacenames = []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func searchPlacesSuggestion() {
        if let userTypedName = searchBar.text {
            if(!userTypedName.isEmpty) {
                let trimmedUserTypedName = userTypedName.trimmingCharacters(in: .whitespacesAndNewlines)
                self.doShowSuggestion(usersQuery: trimmedUserTypedName)
            }
        } else {
            print("Error in searchPlacesSuggestion()")
        }
    }
    
    func doShowSuggestion(usersQuery: String) {
        let urlString = "\(mapbox_api)\(usersQuery).json?access_token=\(mapbox_access_token)"
        print(urlString)

        guard let url = URL(string: urlString) else {
            print("Error in URL() doShowSuggestion()")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error Occured in Retrieving Data in doShowSuggestion()")
                return
            }
            
//            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
//                print(jsonData)
//            }

            do {
                let result = try JSONDecoder().decode(Response.self, from: data)
                self.suggestedPlacenames = result.features
                
                print(self.suggestedPlacenames)
                print(self.suggestedPlacenames.count)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error in Data Decoding in doShowSuggestion()", error)
            }
        }
        task.resume()
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as! HomeViewController
//        print("In Segue preperation",userSelectedPlacesLatitude, userSelectedPlacesLongitude)
//        destinationVC.userSelectedPlacesLatitude = self.userSelectedPlacesLatitude
//        destinationVC.userSelectedPlacesLongitude = self.userSelectedPlacesLongitude
//        destinationVC.reloadWeatherDataStatus = true
//    }
    
}

// MARK:- TableView
extension SearchCityNameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedPlacenames.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "table_cell") as! AutoCompleteLocationCustomTableViewCell
//        cell?.textLabel?.text = suggestedPlacenames[indexPath.row].place_name!
        print(suggestedPlacenames[indexPath.row].place_name!)
        cell.suggestedPlaceName.text = suggestedPlacenames[indexPath.row].place_name!
        cell.placeMarker.image = UIImage(named: "mapMarker")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userSelectedPlacesLatitude = suggestedPlacenames[indexPath.row].geometry.coordinates[1]
//        UserDefaults.standard.set(userSelectedPlacesLatitude, forKey: "userSelectedPlacesLatitudeValue")

        self.userSelectedPlacesLongitude = suggestedPlacenames[indexPath.row].geometry.coordinates[0]
//        UserDefaults.standard.set(userSelectedPlacesLongitude, forKey: "userSelectedPlacesLongitudeValue")

        self.userSelectedPlacesname = self.suggestedPlacenames[indexPath.row].place_name ?? "Error"
//        UserDefaults.standard.set(userSelectedPlacesname, forKey: "userSelectedPlacesnameValue")
        
        do {
            print(Realm.Configuration.defaultConfiguration)
            let realmReference = try Realm()
            
            let weatherInfoObject = StoredWeatherInfos()
            weatherInfoObject.stored_cityName = userSelectedPlacesname
            weatherInfoObject.stored_latitude = userSelectedPlacesLatitude
            weatherInfoObject.stored_longitude = userSelectedPlacesLongitude
        
            
            realmReference.beginWrite()
            realmReference.delete(realmReference.objects(StoredWeatherInfos.self))
            realmReference.add(weatherInfoObject)
            try realmReference.commitWrite()
    
        } catch {
            print("Error in creating Realm Reference or writing in Realm!")
        }
        
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
}
