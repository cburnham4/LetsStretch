//
//  RoutineCell.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import UIKit

class RoutineCell: UITableViewCell {

    @IBOutlet weak var routineImage: UIImageView!
    @IBOutlet weak var routineNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        routineImage.layer.borderWidth = 1
        routineImage.layer.masksToBounds = false
        routineImage.layer.borderColor = UIColor.black.cgColor
        routineImage.layer.cornerRadius = routineImage.frame.height/2
        routineImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
