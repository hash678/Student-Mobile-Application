//
//  LoginHandler.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 19/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
class LoginHandler{
private let commonutil = common_util()

    var viewController:UIViewController?
    
    init(view:UIViewController){
        viewController = view
    }
    
    

    public func userSignedIn(){
        //TODO: Check if phone number is null
        let phoneNumber = commonutil.formatNumber(number:(Auth.auth().currentUser?.phoneNumber!)!)
        self.checkIfUserDataExists(userPhoneNumber: phoneNumber)
        
    }
    
    
    
   private func checkIfUserDataExists(userPhoneNumber: String){
        Firestore.firestore().collection("account_link").document(userPhoneNumber).getDocument { (document, error) in
            if error == nil{
                var accountType = accountTypeGetSet()
                accountType.mode = document?.get("mode") as? String
                accountType.username = document?.get("username") as? String
                if let username = accountType.username, let type = accountType.mode{
                    self.checkAccountType(whatmode: type, username: username)}
            }else{
                //TODO: NSP LOGIN
                
            }
            
        }}
    
    
    
    //Checks account type
   private func checkAccountType(whatmode mode: String, username: String){
        let db = Firestore.firestore()
        db.collection("users").document(username).getDocument { (document, error) in
            if error == nil{
                if  let documentObtained = document{
                    let student = self.commonutil.documentToStudentObject(firebaseDocument: documentObtained)
                    self.commonutil.saveUserData(userObject: student)
                   self.openHomeScreen()
                }}
        }
    }
    
   private func openHomeScreen(){
    print("Open activity")
        let NavigationController = viewController!.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! NavigationController
        viewController!.present(NavigationController, animated: true, completion:nil)
    }
    
    
}
