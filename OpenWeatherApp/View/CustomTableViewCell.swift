//
//  CustomTableViewCell.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 29/3/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var forecastDate: UILabel!
//    @IBOutlet weak var forecastSunriseTime: UILabel!
//    @IBOutlet weak var forecastSunsetTime: UILabel!
    @IBOutlet weak var forecastWeatherIcon: UIImageView!
    @IBOutlet weak var forecastWeatherDescription: UILabel!
    @IBOutlet weak var forecastMinTemp: UILabel!
    @IBOutlet weak var forecastMaxTemp: UILabel!
}
