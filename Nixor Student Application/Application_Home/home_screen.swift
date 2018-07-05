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

    @IBOutlet weak var student_photo: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentIDLabel: UILabel!
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
        setMyData()
    
        }
        
        func setMyData(){
            
            student_photo = commonutil.circleImage(image: student_photo)
            if let username_local = commonutil.getUserData(key: "username"){
                userClass.getMyPhoto(username: username_local, imageview: student_photo!)
                username = username_local
            }
                if let name = commonutil.getUserData(key: "name"){
                    studentNameLabel.text = name
            
                }
            
            if let studentid = commonutil.getUserData(key: "student_id"){
                studentIDLabel.text = studentid
                
            }
            
    }
    
    
   
    
}
