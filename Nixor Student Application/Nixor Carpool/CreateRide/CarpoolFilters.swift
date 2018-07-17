//
//  CarpoolFilters.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 12/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import M13Checkbox
class CarpoolFilters:UIViewController{
    @IBOutlet weak var tuesday: M13Checkbox!
    
    @IBOutlet weak var sunday: M13Checkbox!
    @IBOutlet weak var saturday: M13Checkbox!
    @IBOutlet weak var friday: M13Checkbox!
    @IBOutlet weak var thursday: M13Checkbox!
    @IBOutlet weak var wednesday: M13Checkbox!
    @IBOutlet weak var monday: M13Checkbox!
    @IBOutlet weak var setdaysCheckBox: M13Checkbox!
    @IBOutlet weak var setTimeCheckBox: M13Checkbox!
    @IBOutlet weak var sortBy: UISegmentedControl!
    @IBOutlet weak var taxiOrPrivate: UISegmentedControl!
    @IBOutlet weak var typeOfRide: UISegmentedControl!
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        intializeView()
    }
    
    func intializeView(){
        datePicker.setValue(UIColor.white, forKey: "textColor")
    }
}
