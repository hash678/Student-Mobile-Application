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
class AvailablerideCell: UITableViewCell{
    var itemClicked:String?
    var user:String?
    @IBAction func onRequest(_ sender: Any) {
        delegate?.requestButtonClicked(id:itemClicked,user:user,indexPath: currentIndexPath!)
    }
    @IBOutlet weak var student_name: UILabel!
    @IBOutlet weak var hidingLayout: UIView!
    
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var number_seats: UILabel!
    @IBOutlet weak var ride_time: UILabel!
    @IBOutlet weak var costperHead: UILabel!
    @IBOutlet weak var available_days: UILabel!
    @IBOutlet weak var student_id: UILabel!
    
    @IBOutlet weak var student_photo: UIImageView!
    
    @IBOutlet weak var topView: UIView!
    var delegate:onRequestButtonClicked?
    
    var currentIndexPath:IndexPath?
    let expandedHeight:CGFloat = 324

    
    
    var isObserving = false
    func checkHeight(){
        hidingLayout.isHidden = (frame.size.height < self.expandedHeight)
    }
    func watchFrameChanges(){
        if !isObserving{
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        isObserving = true
            checkHeight()
            
        }
    }
    func ignoreFrameChanges(){
        if isObserving {
        isObserving = false
            removeObserver(self, forKeyPath: "frame")}
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame"{
            checkHeight()
        }
    }
    
}
protocol onRequestButtonClicked {
    func requestButtonClicked(id:String?,user:String?,indexPath:IndexPath)
}
