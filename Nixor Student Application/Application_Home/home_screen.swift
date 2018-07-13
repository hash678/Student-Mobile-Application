//
//  home_screen.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class home_screen: UIViewController {

   
    var commonutil = common_util()
    var userClass = UserPhoto()
    var username:String?
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        initialize()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func initialize(){
     navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        }
        
    
    
    
    
   
    
}
