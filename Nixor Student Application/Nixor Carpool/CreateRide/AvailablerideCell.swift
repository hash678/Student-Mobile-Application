//
//  AvailablerideCell.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 12/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import FoldingCell
class AvailablerideCell: FoldingCell{
    var itemClicked:String?
    var user:String?
    @IBAction func onRequest(_ sender: Any) {
        delegate?.requestButtonClicked(id:itemClicked,user:user,indexPath: currentIndexPath!)
    }
    @IBOutlet weak var student_name: UILabel!
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var number_seats: UILabel!
    @IBOutlet weak var ride_time: UILabel!
    @IBOutlet weak var costperHead: UILabel!
    @IBOutlet weak var available_days: UILabel!
    @IBOutlet weak var student_id: UILabel!
    @IBOutlet weak var student_photo: UIImageView!
    
    
  
    
    
    var delegate:onRequestButtonClicked?
    
    var currentIndexPath:IndexPath?
   
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 5
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.16, 0.16, 0.16]
        return durations[itemIndex]
    }


    
    
}
protocol onRequestButtonClicked {
    func requestButtonClicked(id:String?,user:String?,indexPath:IndexPath)
}
