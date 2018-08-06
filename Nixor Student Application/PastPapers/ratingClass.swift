//
//  ratingClass.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/08/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

class ratingClass{

    private var username:String?
    private let ratingTotal = 5
    private var rating:Int?
    private var ref:DocumentReference?
    
    init(ref:DocumentReference,rating:Int,username:String){
        self.ref = ref
        self.rating = rating
        self.username = username
    }
    
    public func alreadyRated(callback:@escaping (Bool) -> Void){
        if ref != nil, rating != nil, username != nil {
            
           
            ref!.addSnapshotListener({ (snapshot, error) in
                var data = snapshot?.data()
                if data != nil{
                    let ratedUsers = data!["UsersRating"] as! [String]
                    
                    if ratedUsers.contains(self.username!){
                        callback(false)
                    }else{
                        callback(true)
                    }
                    
                }else{
                    callback(false)
                }
                
                
            })
            
            
        }
    }
    
    public func giveRating(callback:() -> Void){
        
        if ref != nil, rating != nil, username != nil {
            

            
            
        }
        
        

        
       
    }
    public func getRating(){
        
        
        
        
    }
    

    
    
    
    
}
