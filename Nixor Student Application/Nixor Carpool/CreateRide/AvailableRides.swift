//
//  AvailableRides.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 12/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import GoogleMaps
import CoreLocation
import FirebaseFunctions
import FirebaseDatabase
import FoldingCell
class AvailableRides:GeneralLayout, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, onRequestButtonClicked, CLLocationManagerDelegate{
   
    
    var locationManager:LocationManager?
    var coreLocationManager = CLLocationManager()
     lazy var functions = Functions.functions()
    @IBOutlet weak var noAvailableRides: UILabel!
    var selectedIndexPath:IndexPath?
      var indicator: UIActivityIndicatorView?
    var rides = [rideData]()
    let userClass = UserPhoto()
    @IBOutlet weak var tableView: UITableView!
   
    let commonUtil = common_util()
    var username:String?
    var handler:ListenerRegistration?
    var campus:String = "Main"
    var usersPhoto = [String:String]()
    var myLat:Double?
    var myLong:Double?
    
 
    
    @IBAction func changeCampusSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: changeCampus("Main")
        case 1: changeCampus("NCFP")
        default: break
        }
    }
    
    
    
    
    
   
    
    
    func getAvailableRides(){

        
      handler = constants.carpoolDB.whereField("mainCampusOrNcfp", isEqualTo: self.campus).addSnapshotListener { (response, error) in
            if error == nil && response != nil {
                self.noAvailableRides.isHidden = true
                       self.resetTableView()
                if response?.count == 0{
                   self.noAvailableRides.isHidden = false
                }
                for documents in response!.documents {
                    let doc:Dictionary = documents.data()
                    self.rides.append(self.mapToRideObject(document: doc,id: documents.documentID))
              
                }
                
                
                if self.myLat != nil{
                    print("SORT BY DISTANCE")
                let coordinate = CLLocation(latitude: self.myLat!, longitude: self.myLong!)
                
                    self.rides =  self.rides.sorted(by: { (coordinate.distance(from: CLLocation(latitude: $0.startDestMyLat, longitude: $0.startDestMyLong))) < (coordinate.distance(from: CLLocation(latitude: $1.startDestMyLat, longitude: $1.startDestMyLong)))
                        
                    })
                    
                }
                
        
                self.hideLoading()
                self.setRidesCount(count:self.rides.count)
               
              
                
                
            }else{
                self.hideLoading()
                self.noAvailableRides.isHidden = false
        }
        }
        
    }
 
    func resetTableView(){
         self.rides = [rideData]()
        setRidesCount(count:self.rides.count)
        showloading()
        
        
      
        
    }
    
    
    func changeCampus(_ campus:String){
        handler?.remove()
        self.campus = campus
        getAvailableRides()
      
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intLoading()
        coreLocationManager.delegate = self
        checkPermissionToAccessLocation()
        self.tableView.rowHeight = 70
        self.hideKeyboardWhenTappedAround()
       username = commonUtil.getUserData(key: "username")
        checkForNewRequestMessages()
       changeCampus("Main")
    }
    
    //MARK: Firebase data to rideData object
    func mapToRideObject(document map:Dictionary<String,Any>,id:String) -> rideData{
        let student_name = map["student_name"] as! String
        let student_id = map["student_id"] as! String
        let student_username = map["student_username"] as! String
        let student_number = map["student_number"] as! String
        let privateCarOrTaxi = map["privateCarOrTaxi"] as! String
        
        let oneTimeOrScheduled = map["oneTimeOrScheduled"] as! String
        var iAmtheDriver:Bool?
        
        if let iAmtheDriver_local = map["iAmtheDriver"] as? Bool{
            iAmtheDriver = iAmtheDriver_local
        }
        
        var selectedDays:Dictionary<String,Bool>?
        if let selectedDays_local = map["selectedDays"] as? Dictionary<String,Bool>{
            selectedDays = selectedDays_local
        }
        
        let selectedTime = map["selectedTime"] as! Double
        let startDestMyLat = map["myLat"] as! Double
        let startDestMyLong = map["myLong"] as! Double
        let route = map["route"] as! String
        let numberOfSeats = map["numberOfSeats"] as! Int
        let estimatedCost = map["estimatedCost"] as! Double
        let totalDistance = map["totalDistance"] as! Double
        let rideDuration = map["rideDuration"] as! String
        let mainCampusOrNcfp = map["mainCampusOrNcfp"] as! String
        let occupiedSeats = map["occupiedSeats"] as! Int
        var summary:String?
        if let summary_local = map["selectedDays"] as? String{
            summary = summary_local
        }
        
        
        let myRide = rideData(student_name: student_name, student_id: student_id, student_number: student_number, student_username: student_username, privateCarOrTaxi: privateCarOrTaxi, iAmtheDriver: iAmtheDriver, oneTimeOrScheduled: oneTimeOrScheduled, selectedDays: selectedDays, selectedTime: selectedTime, startDestMyLat: startDestMyLat, startDestMyLong: startDestMyLong, route: route, numberOfSeats: numberOfSeats, occupiedSeats: occupiedSeats+1, estimatedCost: estimatedCost, totalDistance: totalDistance, rideDuration: rideDuration, mainCampusOrNcfp: mainCampusOrNcfp, summary: summary,id:id)
        return myRide
        
    }
    
    //MARK: Tableview item photo
    func getPhotoUrl(cell:AvailablerideCell, username:String){
        constants.userDB.document(username).getDocument { (response, error) in
            if error == nil && response != nil{
                if response?.get("photourl") != nil{
                          let url = URL(string: response?.get("photourl") as! String)
                    cell.student_photo.kf.setImage(with: url )
                    
                    self.usersPhoto[username] = (response?.get("photourl") as! String)
                }
                
            }
        }
        
    }
    
    
    
    //MARK: Tableview item map
    func setMap(myRide:rideData, cell:AvailablerideCell){
        cell.map.delegate = self
        cell.map.clear()
        let camera = GMSCameraPosition.camera(withLatitude:myRide.startDestMyLat, longitude: myRide.startDestMyLong, zoom: 12.0)
        cell.map.animate(to: camera)
        cell.map.settings.compassButton = true
        cell.map.settings.zoomGestures = true
        cell.map.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: myRide.startDestMyLat, longitude: myRide.startDestMyLong)
        let MyMarkerImage = UIImageView(image: #imageLiteral(resourceName: "myMarker"))
        var rect = MyMarkerImage.frame
        rect.size.height = constants.myMarkerIconSize
        rect.size.width = constants.myMarkerIconSize
        MyMarkerImage.frame = rect
        marker.iconView = MyMarkerImage
        marker.map =  cell.map
        
        var nixorLat:Double?
        var nixorLong:Double?
        
        if myRide.mainCampusOrNcfp == "Main"{
            nixorLat = constants.nixorMainCampuslocation[0]
            nixorLong = constants.nixorMainCampuslocation[1]
        }else{
            nixorLat = constants.nixorNCFPCampusLocation[0]
            nixorLong = constants.nixorNCFPCampusLocation[1]
        }
        
        let Nixormarker = GMSMarker()
        Nixormarker.position = CLLocationCoordinate2D(latitude:nixorLat!, longitude: nixorLong!)
        let NixorMarkerImage = UIImageView(image: #imageLiteral(resourceName: "nixorMarker"))
        var Nixorrect = NixorMarkerImage.frame
        Nixorrect.size.height = constants.nixorMarkerIconSize
        Nixorrect.size.width = constants.nixorMarkerIconSize
        NixorMarkerImage.frame = Nixorrect
        Nixormarker.iconView = NixorMarkerImage
        Nixormarker.map =  cell.map
        
        let points = myRide.route
        let path = GMSPath.init(fromEncodedPath: points!)
        let polyline = GMSPolyline.init(path: path)
        polyline.strokeColor = constants.routeColor
        polyline.strokeWidth = constants.routeWidth
        polyline.map = cell.map
    }
    
    
    
    
    //MARK: Day array to string
    func daysArraytoString(dayArray:Dictionary<String,Bool>) -> String{
        var daysAvailable =  ""
        
        if dayArray["Monday"]! {
            daysAvailable += ", Mon"
        }
        
        if dayArray["Tuesday"]! {
            daysAvailable += ", Tue"
        }
        
        
        if dayArray["Wednesday"]! {
            daysAvailable += ", Wed"
        }
        
        
        if dayArray["Thursday"]! {
            daysAvailable += ", Thu"
        }
        
        
        if dayArray["Friday"]! {
            daysAvailable += ", Fri"
        }
        if dayArray["Saturday"]! {
            daysAvailable += ", Sat"
        }
        if dayArray["Sunday"]! {
            daysAvailable += ", Sun"
        }
        daysAvailable.remove(at: daysAvailable.startIndex)
        daysAvailable.remove(at: daysAvailable.startIndex)
        return daysAvailable
        
    }
    
    
    func setRideInformation(ride object:rideData, cell:AvailablerideCell) -> AvailablerideCell{
        
        //Set cell background and design
        if object.student_name != nil, object.student_id != nil, object.numberOfSeats != nil, object.student_username != nil{
              cell.isHidden = false
            
           
            cell.itemClicked = object.id
          cell.user = object.student_username
            
            //Set map
            setMap(myRide: object, cell: cell)
          
            //Get ride host's image
            
            if let photourl = usersPhoto[object.student_username]{
                cell.student_photo.circleImage()
                let url = URL(string: photourl)
                cell.student_photo.kf.setImage(with: url)
                  }else{
            
                getPhotoUrl(cell: cell, username: object.student_username)}
            
            //Set host's basic information
            
            cell.student_name.text = object.student_name
            cell.student_id.text = object.student_id
            
            //Calculate cost per person. Adding 1 here to account for you
            let costperperson = (object.estimatedCost as Double)/Double(object.occupiedSeats + 1)
            cell.costperHead.text = "\(costperperson.rounded(toPlaces: 0))"
         
            
            //Set number of seats
            cell.number_seats.text = "\(object.numberOfSeats!)"
          
            
            
            //Set ride timings and related information
            
            //If the ride is scheduled
            if object.oneTimeOrScheduled == "scheduled"{
                //Get the name of days for the schedule
                cell.available_days.text = daysArraytoString(dayArray: object.selectedDays!)
              }else{
                 cell.available_days.text = commonUtil.convertSecondsToDateOnly(interval: object.selectedTime)
             }
            
            //Get timing for the schedule
            //Convert seconds to date
            let date = Date.init(timeIntervalSince1970: object.selectedTime)
            //Format date
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            // Format: "4:44 PM"
            
            cell.ride_time.text = dateString
            cell.ride_time.isHidden = false
            
            
            
        }else{
            
            cell.isHidden = true
        }
        return cell
    }
    
    
    let closedHeight:CGFloat = 80
    let openLHeight:CGFloat = 240
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AvailablerideCell", for: indexPath) as! AvailablerideCell
        let durations: [TimeInterval] = [0.26, 0.26, 0.26]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        cell.currentIndexPath = indexPath
        cell.delegate = self
        cell = setRideInformation(ride: rides[indexPath.row], cell: cell)
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as AvailablerideCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == closedHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == closedHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = openLHeight
            cell.unfold(true, animated: true, completion: nil)
            
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = closedHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    
     var cellHeights: [CGFloat] = []
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    
    
    func setRidesCount(count:Int){
          cellHeights = Array(repeating: closedHeight, count: count)
         self.tableView.reloadData()
    }
    
    //MARK: Just some basic loading and shashkay scene
    func intLoading(){
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator!.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        indicator!.center = view.center
        indicator!.color = #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
        self.view.addSubview(indicator!)
        self.view.bringSubview(toFront: indicator!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func hideLoading(){
        if indicator!.isAnimating{
            indicator!.stopAnimating()
        }
        
    }
    func showloading(){
        indicator?.startAnimating()
    }
    
    
    
    
    
    
    
    func requestButtonClicked(id:String?,user:String?,indexPath:IndexPath) {
        if let docid = id, let userID = user {
            createRide(id: docid, user: userID,indexPath:indexPath)
           
        }
    
    }
    
    func createRide(id:String, user:String, indexPath:IndexPath){
        
        let users = [user,username]
        print("Cloud function called")
        let dataToSave:Dictionary<String,Any> = ["users":users,"Date":Timestamp().seconds,"RideOwner":user]
        
        let data:[String:Any] = ["username1":user,"username2":username!,"map":dataToSave,"id":id]
        
        functions.httpsCallable("carpool_function").call(data) { (response, error) in
            if error == nil && response != nil{
                self.tabBarController?.selectedIndex = 2
                
            }else if error != nil {
                self.commonUtil.showAlert(title: "Request failed", message: "Please make sure you are connected to the internet. If this problem persists please contact Nixor College", buttonMessage: "OK", view: self)
               
            }
            
        }
        
        
        
        
     
        
        
    }
    
    
    
    //MARK: Check permission to access user's location
    func checkPermissionToAccessLocation(){
        let authorizationCode = CLLocationManager.authorizationStatus()
        
        if authorizationCode == CLAuthorizationStatus.notDetermined && coreLocationManager.responds(to:#selector(CLLocationManager.requestAlwaysAuthorization)){
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil{
                coreLocationManager.requestAlwaysAuthorization()
            }else{
                print("No description available")
            }
        }else{
            getLocation()
            
        }
    }
    
    //MARK: Gets location using location Manager class
    func getLocation(){
        locationManager = LocationManager.sharedInstance
        locationManager?.startUpdatingLocationWithCompletionHandler({ (lat, long, status, verbMessage, error) in
            self.myLat = lat
            self.myLong = long
        })
    }
    
    
    
    
    //All methods below are for checking for new messages and showing badges accordingly
    
    var newMessageListeners = [DatabaseReference]()
    
    func newMessageIdsAdded(){
        let newMessageCount = newMesagesIDS.count
        
        if let tabbaritem = self.tabBarController?.tabBar.items?[2]{
        if newMessageCount > 0{
            tabbaritem.badgeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            tabbaritem.badgeValue = "\(newMessageCount)"
            let attribute : [String : Any] = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]
            tabbaritem.setBadgeTextAttributes(attribute, for: .normal)
        }else{
            tabbaritem.badgeValue = nil
        }
    }
    }
    var newMesagesIDS = [String]()
        
     
    
  
    
    
    func checkEachMessageNodeForNewMessages(id:String){
        
       // print(id)
        constants.CarpoolMessagesDB.child(id).queryOrderedByKey().queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            for snaps in snapshot.children{
                let data = snaps as! DataSnapshot
         
               //print(data)
                let usersender = data.childSnapshot(forPath: "username").value as? String
                if usersender != self.username {
                    if !self.newMesagesIDS.contains(data.key){
                    self.newMesagesIDS.append(data.key)
                        self.newMessageIdsAdded()}
                   
                }else{
                    if self.newMesagesIDS.contains(data.key){
                        self.newMesagesIDS.remove(at: self.newMesagesIDS.index(of: data.key)!)
                        self.newMessageIdsAdded()
                    }
                }
                
            }
        }) { (error) in
            print(error)
        }
        
      newMessageListeners.append(constants.CarpoolMessagesDB.child(id))
        
        
    }
    
    func checkForNewRequestMessages(){
             newMesagesIDS = [String]()
        constants.userCarpoolMessagesDB.child(username!).observeSingleEvent(of: .value) { (datasnaphot) in
          //  print(datasnaphot)
            for snaps in datasnaphot.children{
                print(snaps)
                let id = (snaps as! DataSnapshot).key
                self.checkEachMessageNodeForNewMessages(id: id)
            }
            
        }
        
    }
    
    
    
    
}
