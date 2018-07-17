//
//  ConversationsList.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 15/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseDatabase
class ConversationsList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    var convoList = [conversation]()
    var chatIDS = [String]()
    var userPhotos = [String:String]()
    var userIDS = [String:String]()
    var username:String?
    var db:DatabaseReference?
    let commonUtil = common_util()
    
    var chatID:String?
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let NavigationController = storyboard?.instantiateViewController(withIdentifier: "CarpoolDM") as! CarpoolDM
        NavigationController.id = chatIDS[indexPath.item]
     self.navigationController?.pushViewController(NavigationController, animated: true)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationItemTableViewCell") as! ConversationItemTableViewCell
        
        cell.student_name.text = convoList[indexPath.item].user
        cell.setCardView()
        
        let dateSelected = Date.init(timeIntervalSince1970: convoList[indexPath.item].date!)
        //Format date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: dateSelected)
        cell.date.text = dateString
        
        if let photourl = self.userPhotos[convoList[indexPath.item].user!] {
            let url = URL(string: photourl)
            cell.student_photo.kf.setImage(with: url)
            cell.student_id.text = self.userIDS[convoList[indexPath.item].user!]
        }else{
            self.getPhotoUrl(cell: cell, username: convoList[indexPath.item].user!)
        }
        return cell
    }
    

   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableFooterView = UIView()
        self.tableview.rowHeight = 75
        username = commonUtil.getUserData(key: "username")
        db =  constants.userCarpoolMessagesDB.child(username!)
        getChatInfo()
    }
    
    func getChatInfo(){
        self.convoList = [conversation]()
        constants.userCarpoolMessagesDB.child(username!).observe(.value) { (snapshot) in
            for snaps in snapshot.children{
             
              if let snapshots = snaps as? DataSnapshot{
                    
                   let convo = self.getDataFromSnapshot(data: snapshots, key: snapshots.key)
                if !self.chatIDS.contains(convo.chatID!){
                         self.convoList.append(convo)
                    self.chatIDS.append(convo.chatID!)
                }
                }else{
                    print("Casting failed")
                }
            }
            self.tableview.reloadData()
        }
        
    }
    
    

    func getPhotoUrl(cell:ConversationItemTableViewCell, username:String){
        constants.userDB.document(username).getDocument { (response, error) in
            if error == nil && response != nil{
                
                if response?.get("photourl") != nil{
                    let url = URL(string: response?.get("photourl") as! String)
                    cell.student_photo.kf.setImage(with: url )
                    self.userPhotos[username] = (response?.get("photourl") as! String)
                }
                if let studentid = response?.get("student_id") as? String  {
                    cell.student_id.text = studentid
                    self.userIDS[username] = studentid
                }
                
            }
        }
        
    }
    
    
    
    
    
    
    func getDataFromSnapshot(data:DataSnapshot, key:String) -> conversation{
        
        if let snapshot = data.value as? [String:Any]{
         
            print(snapshot)
            var nameOfUser:String?
            
            let users = snapshot["users"] as! [String]
            
            for values in users{
    // if values != username! {
                    nameOfUser = values
    //   }
            }
            
            let date:Double = snapshot["Date"] as! Double
            let id:String = key
            
            
            let convo = conversation(user: nameOfUser, chatID: id, date: date)
            print(convo)
            return convo
        }else{
            print("Cant convert")
        }
        return conversation(user: nil, chatID: nil, date: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
}
    struct conversation{
       var user:String?
        var chatID:String?
        var date:Double?
    }

        


