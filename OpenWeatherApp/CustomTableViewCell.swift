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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
