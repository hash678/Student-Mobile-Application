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
    
    
    @IBOutlet weak var student_id2: UILabel!
    @IBOutlet weak var ride_time2: UILabel!
    
    @IBOutlet weak var number_seats2: UILabel!
    @IBOutlet weak var student_photo2: UIImageView!
    
    @IBOutlet weak var student_name2: UILabel!
    
    @IBOutlet weak var costperHead2: UILabel!
    
    @IBOutlet weak var available_days2: UILabel!
    
    
    var delegate:onRequestButtonClicked?
    
    var currentIndexPath:IndexPath?
   
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }


    
    
}
protocol onRequestButtonClicked {
    func requestButtonClicked(id:String?,user:String?,indexPath:IndexPath)
}
