//
//  Maintain.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 26/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseDatabase
class Maintain{
    
   public func postClassNames(){
        let asClasses = ["BST103", "CHM106", "CHM107", "CHM101", "FUR101", "CHM104", "CHM103", "CMP101", "CHM102", "BST101", "LAW101", "CHM105", "CMP102", "CMP111", "CHM111", "BST112", "CHM112", "BST111", "ACC104", "ACC101", "PHY104", "ACC103", "PHY102", "PHY103", "ACC102NP", "PSY103", "PHY106", "PSY101", "PHY101", "PSY104", "PSY102", "PHY107", "PHY105", "PSY113", "PHY111", "ACC112", "ACC111", "PHY112", "ACC113", "PSY111", "PSY112", "MTH106", "MTH112", "SOC102", "MTH105", "MTH108", "MTH107", "BIO102", "MTH101", "SOC101", "MTH103", "MTH102", "BIO101", "MTH104", "BIO104", "BIO111", "MTH114", "SOC112", "MTH113", "SOC111", "ECO101", "ECO102", "ECO103"]
        let a2Classes = ["CHM203", "CHM204", "BST201", "CHM201", "BST203", "BST202", "CHM205", "CHM202", "CMP201", "LAW201", "CHM206", "ACC201", "PSY202", "ACC205", "PSY201", "ACC202", "PSY204", "PSY203", "ACC203", "PHY203", "PHY202", "PHY201", "PHY204", "ACC204", "PHY205", "MTH204S", "SOC202", "BIO202", "MTH201S", "MTH202M", "MTH203S", "SOC201", "MTH205S", "BIO201", "MTH209M", "FUR201", "MTH207M", "MTH206S", "URD202", "MTH208S", "URD201"]
        
        
        let allClasses = asClasses + a2Classes
        Database.database().reference().child("ClassList").child("AsClasses").setValue(asClasses);
        Database.database().reference().child("ClassList").child("A2Classes").setValue(a2Classes);
        Database.database().reference().child("ClassList").child("All").setValue(allClasses);
        
    }
}
