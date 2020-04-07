//
//  DirectionsTableViewCell.swift
//  SafeWalk
//
//  Created by Ilana Shapiro on 4/6/20.
//  Copyright © 2020 Ilana Shapiro. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {
    @IBOutlet weak var directionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
