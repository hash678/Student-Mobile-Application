//
//  LaunchScreenViewController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 19/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseDatabase
class LaunchScreenViewController: UIViewController {
    var handler:LoginHandler? 
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        handler = LoginHandler(view: self)
        
        if commonutil.getUserData(key: "HasRunBefore") == nil && Auth.auth().currentUser != nil{
            do {
                try Auth.auth().signOut()
                
            }catch let err {
                print(err)
            }
            checkAuth()
            commonutil.storeinUserDetails(key: "HasRunBefore", value: "true")
        }else{
            checkAuth()
        }
        
    }

   
    
    func checkAuth(){
        
        if  Auth.auth().currentUser != nil{
          handler?.userSignedIn()
        }else{
            openLoginViewController()
        }
    }
    private func openLoginViewController(){
        print("Open login controller")
        print("Open activity")
        let AuthNavigationController = storyboard?.instantiateViewController(withIdentifier: "AuthNavigationController") as! AuthNavigationController
        present(AuthNavigationController, animated: true, completion:nil)
        
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}
