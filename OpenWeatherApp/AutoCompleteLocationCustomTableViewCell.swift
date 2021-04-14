//
//  AutoCompleteLocationCustomTableViewCell.swift
//  OpenWeatherApp
//
//  Created by Fahim Rahman on 14/4/21.
//

import UIKit

class AutoCompleteLocationCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var placeMarker: UIImageView!
    @IBOutlet weak var suggestedPlaceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
