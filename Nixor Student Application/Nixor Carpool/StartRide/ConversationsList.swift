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
    var myRidesList = [conversation]()
    var otherRidesList = [conversation]()
    var selectedRideList = [conversation]()
    var chatIDS = [String]()
    var userPhotos = [String:String]()
    var userIDS = [String:String]()
    var showRidesFor:requestType = requestType.All
    var username:String?
    var db:DatabaseReference?
    let commonUtil = common_util()
    var conversationRef = [DatabaseReference]()
    var chatID:String?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let NavigationController = storyboard?.instantiateViewController(withIdentifier: "CarpoolDM") as! CarpoolDM
        NavigationController.id = convoList[indexPath.row].chatID
        self.navigationController?.pushViewController(NavigationController, animated: true)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRideList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationItemTableViewCell") as! ConversationItemTableViewCell
        
        cell.student_name.text = selectedRideList[indexPath.item].user
        cell.setCardView()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        cell.date.text = commonUtil.convertSecondsToDate(interval: selectedRideList[indexPath.item].date!)
        
        if let photourl = self.userPhotos[selectedRideList[indexPath.item].user!] {
            let url = URL(string: photourl)
            cell.student_photo.kf.setImage(with: url)
            cell.student_photo.circleImage()
            cell.student_id.text = self.userIDS[selectedRideList[indexPath.item].user!]
        }else{
            self.getPhotoUrl(cell: cell, username: selectedRideList[indexPath.item].user!)
        }
        
        
        let convo = self.convoList[indexPath.row]
        
            if let messageText = convo.lastMessage {
                if convo.lastMessageUser != self.username {
                    cell.lastMessage.font = UIFont.boldSystemFont(ofSize: 15.0)
                }else{
                    cell.lastMessage.font =  UIFont.systemFont(ofSize: 15.0)
                }
                cell.date.text = self.commonUtil.convertSecondsToDate(interval: convo.lastMessageDate!)
                cell.lastMessage.text = messageText
            }
        
        
        return cell
    }
    
    
    
    func sortConvoByDate(){
        convoList = convoList.sorted(by: {$0.lastMessageDate > $1.lastMessageDate})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableFooterView = UIView()
        self.tableview.rowHeight = 60
        self.hideKeyboardWhenTappedAround()
        if let tabbaritem = self.tabBarController?.tabBar.items?[2]{
        
                tabbaritem.badgeValue = nil
            
        }

        username = commonUtil.getUserData(key: "username")
        db =  constants.userCarpoolMessagesDB.child(username!)
        getChatInfo()
    }
    
    func getChatInfo(){
        self.selectedRideList = [conversation]()
        constants.userCarpoolMessagesDB.child(username!).queryOrdered(byChild: "Date").observe(.value) { (snapshot) in
            for snaps in snapshot.children{
                
                if let snapshots = snaps as? DataSnapshot{
                    
                    let convo = self.getDataFromSnapshot(data: snapshots, key: snapshots.key)
                    if !self.chatIDS.contains(convo.chatID!){
                        
                        if ((snapshots.value as! [String:Any])["RideOwner"] as! String) == self.username {
                            self.myRidesList.append(convo)
                        }else{
                            self.otherRidesList.append(convo)
                        }
                        
                        self.convoList.append(convo)
                        self.chatIDS.append(convo.chatID!)
                        
                        self.getLastMessageConversation(convo)
                    }
                }else{
                    print("Casting failed")
                }
            }
            self.checkRequestType()
            
        }
        
    }
    
    func checkRequestType(){
        if showRidesFor == requestType.All {
            selectedRideList = convoList
        }else if showRidesFor == requestType.myRides{
            selectedRideList = myRidesList
        }else{
            selectedRideList = otherRidesList
        }
        self.selectedRideList.reverse()
        self.tableview.reloadData()
    }
    
    
    func getPhotoUrl(cell:ConversationItemTableViewCell, username:String){
        constants.userDB.document(username).getDocument { (response, error) in
            if error == nil && response != nil{
                
                if response?.get("photourl") != nil{
                    let url = URL(string: response?.get("photourl") as! String)
                    cell.student_photo.kf.setImage(with: url )
                    cell.student_photo.circleImage()
                    
                    
                    
                    
                    self.userPhotos[username] = (response?.get("photourl") as! String)
                }
                if let studentid = response?.get("student_id") as? String  {
                    cell.student_id.text = studentid
                    self.userIDS[username] = studentid
                }
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            //TODO: Add end request func
            
            print("index path of delete: \(indexPath)")
            completionHandler(true)
        }
        let confirm = UIContextualAction(style: .destructive, title: "Confirm") { (action, sourceView, completionHandler) in
            //TODO: Add confirm request func
            
            print("index path of confirm: \(indexPath)")
            completionHandler(true)
        }
        delete.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        confirm.backgroundColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete, confirm])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    
    

    
    
    func getLastMessageConversation(_ conversa:conversation){
        var convo = conversa
        constants.CarpoolMessagesDB.child(convo.chatID!).queryOrderedByKey().queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            for snaps in snapshot.children{
                let data = snaps as! DataSnapshot
                
                //  print(data)
                let message = data.childSnapshot(forPath: "message").value as? String
                let usersender = data.childSnapshot(forPath: "username").value as? String
                let date =  data.childSnapshot(forPath: "date").value as? Double
                //print("\(message) message")
                
                if let messageText = message {
                   convo.lastMessage = messageText
                    convo.lastMessageUser = usersender
                    convo.lastMessageDate = date
                }
                let index = self.indexOf(list: self.convoList, chatID: convo.chatID!)
                self.convoList[index] = convo
            }
            self.sortConvoByDate()
            self.tableview.reloadData()
            
        }) { (error) in
            print(error)
        }
        conversationRef.append(constants.CarpoolMessagesDB.child(convo.chatID!))
        
    }
    
 
    func removeAllListeners(){
        for indexPath in conversationRef.indices{
            conversationRef[indexPath].removeAllObservers()
        }
    }
    
    func indexOf(list:[conversation], chatID:String) -> Int{
        let index = 0
        
        for indexPath in list.indices{
            if list[indexPath].chatID == chatID{
                return indexPath}
        }
        
        return index
        
    }
    
    func getDataFromSnapshot(data:DataSnapshot, key:String) -> conversation{
        
        if let snapshot = data.value as? [String:Any]{
            
            print(snapshot)
            var nameOfUser:String?
            
            let users = snapshot["users"] as! [String]
            
            for values in users{
                nameOfUser = values
                
            }
            
            let date:Double = snapshot["Date"] as! Double
            
            let id:String = key
            
           
            let convo = conversation(user: nameOfUser, chatID: id, date: date, lastMessage: nil, lastMessageUser: nil, lastMessageDate: date)
            print(convo)
            return convo
        }else{
            
            print("Cant convert")
        }
       
         let myDate = Date().timeIntervalSince1970
        return conversation(user: nil, chatID: nil, date: nil, lastMessage: nil, lastMessageUser: nil, lastMessageDate: myDate)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    
    
    
    
    
    @IBAction func changeRideList(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: showRidesFor = .All
        case 1: showRidesFor = .myRides
        case 2: showRidesFor = .other
        default: break
            
        }
        checkRequestType()
    }
    
}


enum  requestType{
    case All
    case myRides
    case other
}
struct conversation{
    var user:String?
    var chatID:String?
    var date:Double?
    var lastMessage:String?
    var lastMessageUser:String?
    var lastMessageDate:Double!
   
    
}




