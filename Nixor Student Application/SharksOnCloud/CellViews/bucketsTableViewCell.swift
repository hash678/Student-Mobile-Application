//
//  bucketsTableViewCell.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 19/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit

class bucketsTableViewCell: UITableViewCell {
    @IBOutlet weak var student_name: UILabel!
    @IBOutlet weak var class_type: UILabel!
    
    @IBOutlet weak var student_photo: UIImageView!
    @IBOutlet weak var nixor_points: UILabel!
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
