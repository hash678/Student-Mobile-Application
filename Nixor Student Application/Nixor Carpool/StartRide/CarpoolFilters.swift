//
//  CarpoolFilters.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 12/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
class CarpoolFilters:UIViewController{
    
    
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
