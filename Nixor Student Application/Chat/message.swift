//
//  message.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 15/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
struct message{
    
    var message:String?
    var user:String?
    var timestamp:String?
    
    init(map:Dictionary<String,Any>){
        user = map["user"] as? String
        message = map["message"] as? String
        timestamp = map["timestamp"] as? String
        
    }
   
}



