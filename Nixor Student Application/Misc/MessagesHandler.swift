//
//  MessagesHandler.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 15/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import  FirebaseDatabase
import FirebaseStorage
import Firebase
protocol MessageReceieved: class {
    func messageReceived(senderID:String, text:String, displaname:String,messageID:String)
}
class MessagesHandler{
    
    public static var db:DatabaseReference?
    weak var delegate:MessageReceieved?
    private static let _instance = MessagesHandler()
    private init(){}
    
    static var Instance: MessagesHandler{
        return _instance
    }
    func sendMessage(senderID:String, senderName:String, text:String){
        
        let data:Dictionary<String, Any> = ["username":senderID,"student_name":senderName,"message":text,"date":Timestamp().seconds]
        
        MessagesHandler.db!.childByAutoId().setValue(data)
        
    }
    
    func observerMessages(){
        
        MessagesHandler.db!.observe(.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let senderID = data["username"] as? String{
                    if let text = data["message"] as? String, let displayname = data["student_name"] as? String{
                        self.delegate?.messageReceived(senderID: senderID, text: text, displaname:displayname,messageID: snapshot.key)
                    }
                    
                }
                
                
                
                
            }
        }
        
    }
    
    
    
}








