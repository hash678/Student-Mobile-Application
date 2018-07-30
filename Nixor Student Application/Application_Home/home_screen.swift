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
class home_screen: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {
 
    
    var commonutil = common_util()
    var userClass = UserPhoto()
    var username:String?
    var nspButtons = [String]()
    
    @IBOutlet weak var tableview: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nspButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nspCell", for: indexPath) as! nspCell
        cell.name.text = nspButtons[indexPath.row]
        cell.photo.image = getIconForItem(name: nspButtons[indexPath.row])
        return cell
    }
    
    func getIconForItem(name:String)-> UIImage{
        var returnImage = UIImage()
        switch(name){
        case "Profile": returnImage = #imageLiteral(resourceName: "newprofile")
        case "Student Marks": returnImage = #imageLiteral(resourceName: "newstudentmarks")
        case "Gate Attendance": returnImage = #imageLiteral(resourceName: "newgateattendance")
        case "Attendance": returnImage = #imageLiteral(resourceName: "attendance")
        case "Schedule": returnImage = #imageLiteral(resourceName: "newschedule")
        case "TA Log": returnImage = #imageLiteral(resourceName: "talogicon")
        case "TA Schedule": returnImage = #imageLiteral(resourceName: "taicon")
        case "Finance": returnImage = #imageLiteral(resourceName: "newfinance")
        
        default: break
        }
        

        
        return returnImage
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
         initialize()
        
        username = commonutil.getUserData(key: "username")
        commonutil.checkActivation(username: username!, view: self)
        getNspButtons()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        }
    
    

    func getNspButtons(){
        constants.userDB.document(username!).getDocument { (snapshot, error) in
            if snapshot != nil{
                if let value = snapshot!["NspButtons"] {
                    self.nspButtons = value as! [String]
                    self.tableview.reloadData()
                }
                
            }
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func initialize(){
     navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        }
        
    
    
    
    
   
    
}
