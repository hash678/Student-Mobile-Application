//
//  StudentDetails.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import JASON
struct StudentDetails{
    var student_name:String?
    var student_id:String?
    var student_email:String?
    var student_year:String?
    var student_house:String?
    var student_profileUrl:String?
    var student_guid:String?
    
    
    //
    //                    JSON(object: Optional({
    //                        GUID = "d1adcef1-81c0-4c46-8289-cbf7fd06084b";
    //                        "profile_url" = "https://nsp.braincrop.net/File?id=24747";
    //                        studentEmail = "hassan.abbasi@nixorcollege.edu.pk";
    //                        studentHouse = "BLACK TIPS";
    //                        studentID = 2019618;
    //                        studentName = "Hassan Anjum Abbasi";
    //                        studentYear = "Class of 2019";
    //                    }))
    
    
    init(){}
    init(jsonObject:JSON)
    {
        student_name = jsonObject["studentName"].stringValue
        student_id = jsonObject["studentID"].stringValue
        student_email = jsonObject["studentEmail"].stringValue
        student_house = jsonObject["studentHouse"].stringValue
        student_year = jsonObject["studentYear"].stringValue
        student_guid = jsonObject["GUID"].stringValue
        student_profileUrl = jsonObject["profile_url"].stringValue
        
        
    }
    
}
