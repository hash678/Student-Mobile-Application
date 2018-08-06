//
//  subjectCellTableViewCell.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 06/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit

class subjectCellTableViewCell: UITableViewCell {

    var indexpath:IndexPath?
    var addedToFav:Bool = false
    var delegate:addToFav?
    @IBAction func addToFavButton(_ sender: Any) {
        if !addedToFav{
            delegate?.addToFav(sender:indexpath!)
        }else{
            delegate?.addToFav(sender:indexpath!)
        }
    }
    @IBOutlet weak var favIcon: UIButton!
    @IBOutlet weak var subjectName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
