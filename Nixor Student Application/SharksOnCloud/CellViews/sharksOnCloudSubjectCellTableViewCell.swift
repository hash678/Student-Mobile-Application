//
//  sharksOnCloudSubjectCellTableViewCell.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 19/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit


protocol addToFav{
    func addToFav(added:Bool)
    
}

class SubjectCellTableViewCell: UITableViewCell {

    var addedToFav:Bool = false
    var delegate:addToFav?
    
    @IBOutlet weak var heartButton: UIButton!
    @IBAction func favButton(_ sender: UIButton) {
        if !addedToFav{
            delegate?.addToFav(added:true)
        }else{
            delegate?.addToFav(added:false)
        }
        
    }

    @IBOutlet weak var subject_name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
