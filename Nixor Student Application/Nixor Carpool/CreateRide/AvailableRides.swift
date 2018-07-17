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
import FirebaseFunctions
class AvailableRides:UIViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, onRequestButtonClicked{
   
    
    
   
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
    
    
 
    
    @IBAction func changeCampusSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: changeCampus("Main")
        case 1: changeCampus("NCFP")
        default: break
        }
    }
    
   
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
                
                
            
            
                self.hideLoading()
                self.tableView.reloadData()
                
                
            }else{
                self.hideLoading()
                self.noAvailableRides.isHidden = false
        }
        }
        
    }
 
    func resetTableView(){
         self.rides = [rideData]()
        showloading()
          self.tableView.rowHeight = 70
         self.tableView.reloadData()
      
        
    }
    
    
    func changeCampus(_ campus:String){
        handler?.remove()
        self.campus = campus
        getAvailableRides()
        if selectedIndexPath != nil {
            resetRows(indexPath: selectedIndexPath!)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intLoading()
        self.tableView.rowHeight = 70
       username = commonUtil.getUserData(key: "username")
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
        cell.topView.setCardView()
        cell.hidingLayout.setCardView()
        
      
     
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
                
                //If the ride is a one time thing
                let dateSelected = Date.init(timeIntervalSince1970: object.selectedTime)
                //Format date
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                
                let dateString = formatter.string(from: dateSelected)
                // Format: "4:44 PM on June 23, 2016\n"
                cell.available_days.text = dateString
                cell.ride_time.isHidden = true
            }
            
        }else{
            
            cell.isHidden = true
        }
        return cell
    }
    
    
    
    
    //Below are the methods for the tableView.
    
    //Function for count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
         return rides.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AvailablerideCell", for: indexPath) as! AvailablerideCell
        cell.delegate = self
       
        if indexPath.row >= rides.count{
            cell.isHidden = true
            return cell
        }else{
            cell.currentIndexPath = indexPath
            cell = setRideInformation(ride: rides[indexPath.row], cell: cell)
            return cell
            
        }}
    

    func resetRows(indexPath:IndexPath){
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath{
            selectedIndexPath = nil
        }else{
            selectedIndexPath = indexPath
        }
        var indexPaths : Array<IndexPath> = []
        if let previous = previousIndexPath{
            indexPaths.append(previous)
        }
        if let current = selectedIndexPath{
            indexPaths.append(current)
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with:.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.rowHeight = 70
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath{
         selectedIndexPath = nil
        }else{
            selectedIndexPath = indexPath
        }
        var indexPaths : Array<IndexPath> = []
        if let previous = previousIndexPath{
            indexPaths.append(previous)
        }
        if let current = selectedIndexPath{
            indexPaths.append(current)
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with:.automatic)
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        (cell as! AvailablerideCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        (cell as! AvailablerideCell).ignoreFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return 324
        }else{
            return 70
        }
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
        let dataToSave:Dictionary<String,Any> = ["users":users,"Date":Timestamp().seconds]
        let data:[String:Any] = ["username1":user,"username2":username!,"map":dataToSave,"id":id]
        
        functions.httpsCallable("carpool_function").call(data) { (response, error) in
            print(error)
            print(response)
            if error == nil && response != nil{
                self.resetRows(indexPath: indexPath)
                self.tabBarController?.selectedIndex = 2
                
            }else if error != nil {
                self.showToast(message: error.debugDescription)
            }
            
        }
        
        
        
        
     
        
        
    }
    
    
    
    
    
    
    
}
