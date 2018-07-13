//
//  paperCellTableViewCell.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 07/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit


class paperCellTableViewCell: UITableViewCell {

    @IBOutlet weak var monthImage: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var variantLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
