//
//  initialRideData.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 11/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
struct initalRideData{
    
    var student_name:String!
    var student_id:String!
    var student_number:String!
    var student_username:String!
    
    var privateCarOrTaxi:String!
    var iAmtheDriver:Bool?
    
    var oneTimeOrScheduled:String!
    var selectedDays:Dictionary<String, Bool>?
    var selectedTime:Double!
}
