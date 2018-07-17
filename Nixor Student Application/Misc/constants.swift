//
//  constants.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 13/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseDatabase
struct constants{
    public static let myMarkerIconSize:CGFloat = 7
    public static let nixorMarkerIconSize:CGFloat = 30
    public static let routeColor =  #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
    public static let routeWidth:CGFloat = 4
    public static let nixorMainCampuslocation = [24.804291, 67.058710]
    public static let nixorNCFPCampusLocation = [24.791834, 67.065986]
    public static let userDB =  Firestore.firestore().collection("users")

    
    public static let CarpoolMessagesDB:DatabaseReference = Database.database().reference().child("messages")
    //
    public static let pastpaperSubjectDB = Firestore.firestore().collection("Past Papers").document("names")
    
    public static let pastpaperSubjects = Firestore.firestore().collection("Past Papers").document("Subjects")
    
    //Messages displayed
   public static let carpoolRideNotBooked = "We could not post your ride. Please make sure you are connected to the internet."
    public static let carpoolRideBooked = "Congratulations your ride has been posted. 10 Nixor points for you!"
    
    //Carpool Available rides node
    public static let carpoolDB:CollectionReference = Firestore.firestore().collection("Carpool").document("Rides").collection("AvailableRides");
    
    //Create ride conversation node
    public static let userCarpoolMessagesDB = Database.database().reference().child("user-messages")

    
}
