//
//  PastpapersFilter.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 21/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit


protocol applyFilter {
    func applyFilter()
}
class PastpapersFilter: UIViewController {
    
 
    
   //Sort selection
    @IBOutlet weak var sort_by: UISegmentedControl!
    @IBOutlet weak var sortBy: UISegmentedControl!
    
    
    
    //Type selection
    @IBOutlet weak var type_selection: UISegmentedControl!
    @IBAction func typeSelection(_ sender: UISegmentedControl) {
    }
    
    //Month selection
    @IBOutlet weak var month_selection: UISegmentedControl!
    @IBAction func monthSelection(_ sender: UISegmentedControl) {
    }
    
    //year fields
    @IBOutlet weak var yearfieldOne: UITextField!
    @IBOutlet weak var yearfieldtwo: UITextField!
    @IBOutlet weak var toLabel: UILabel!
    
    //Range or specific year
    @IBOutlet weak var year_selection: UISegmentedControl!
    @IBAction func yearSelection(_ sender: UISegmentedControl) {
    }
    
    
    
    //Reset button
    @IBAction func reset(_ sender: UIButton) {
    }
    
    //Cancel button
    @IBAction func cancel(_ sender: UIButton) {
    }
    
    
    
    //Apply button
    @IBAction func apply(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

 
}

enum yearSelection{
    case specific
    case range
}
