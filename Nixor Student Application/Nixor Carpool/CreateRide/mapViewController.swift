//
//  createRide.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 09/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import JASON
import FirebaseFunctions
import Firebase
import FirebaseFirestore
class mapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
   
    let constantClass = constants()
    
    //My location variables
    var myLat:Double?
    var myLong:Double?
    
    //Design values that need to be changed
 
    
    var costPerKM:Double{
        get{
            if initalRideDataFilled?.privateCarOrTaxi == "privateCar"{
                return costPerKMPrivateCar
            }else{
                return costPerKMTaxi
            }
        }
    }
    let costPerKMPrivateCar:Double = 20
    let costPerKMTaxi:Double = 30
    
    public var initalRideDataFilled:initalRideData?
    
  
    
    var numberOfSeats:Int = 1 {
        didSet{
       
            setCostPerhead()
        
        }
    }
    var startDestination:String?
    var distance:Double?{
        
        didSet{
            if let dist = distance {
            distance_field.text = "\(dist) km"
            let estimatedCost = costPerKM * dist
            estimated_field.text = "\(estimatedCost)"
            self.estimatedCost = estimatedCost
            }}
    }
    
    
   
    
    var duration:String?{
        didSet{
            duration_field.text = "\(duration!)"
        }
    }
    
    
    var estimatedCost:Double? {
        didSet{
            setCostPerhead()
        }
    }
    var costPerPerson:Double = 0{
        didSet{
            if costPerPerson == 0{
                costperhead_field.isHidden = true
            }else{
                
                 costPerPerson = costPerPerson.rounded(toPlaces: 0)
                costperhead_field.text = "Rs \(costPerPerson)"
                
                costperhead_field.isHidden = false
            }
        }
    }
    
    var campusSelected = campus.Main{
        didSet{
            switch(campusSelected){
            case campus.Main: addNixorMainCampusMarker()
            case campus.NCFP: addNixorNCFPCampusMarker()
            }
            
        }
    }
    var numberOfRoutes = 0 {
        didSet{
            if numberOfRoutes == 0 {
                routesButtons.isHidden = true
            }else{
                routesButtons.removeAllSegments()
                
                for count in 0..<numberOfRoutes{
                    routesButtons.insertSegment(withTitle: "Route \(count+1)", at: count, animated: true)
                }
                
                routesButtons.isHidden = false
            }
        }
    }
    
    
    
    
    //Storyboard variables
    @IBOutlet weak var routesButtons: UISegmentedControl!
    @IBOutlet weak var campusSelector: UISegmentedControl!
    @IBOutlet weak var mainMap: GMSMapView!
    
    @IBOutlet weak var duration_field: UITextField!
    
    @IBOutlet weak var distance_field: UITextField!
    
    @IBOutlet weak var estimated_field: UITextField!
    
    @IBOutlet weak var costperhead_field: UITextField!
    
    @IBOutlet weak var numberofseats_field: UITextField!
    
    
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let commonutil = common_util()
    let userClass = UserPhoto()
    lazy var functions = Functions.functions()
    var allAvailableRoutes = [routeInformation]()
    var coreLocationManager = CLLocationManager()
    var locationManager:LocationManager?
    var username:String?
    var myRoute:String?
    var rideDataFilled:rideData?
    var summary:String?
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        username = commonutil.getUserData(key: "username")
        mainMap.delegate = self
        coreLocationManager.delegate = self
        campusSelected = campus.Main
        checkPermissionToAccessLocation()
        self.hideKeyboardWhenTappedAround()
        self.estimated_field.keyboardType = UIKeyboardType.numberPad
        
        let newNextButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: #selector(mapViewController.next(sender:)))
        
        self.navigationItem.rightBarButtonItem = newNextButton
            self.navigationItem.hidesBackButton = true
       
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(mapViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func next(sender: UIBarButtonItem) {
        postMyRide()
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
            self.initializeMap(lat:lat, long:long)
        })
    }
    
    
    //MARK: Zoom's Map to my location
    func initializeMap(lat:Double, long:Double){
        myLat = lat
        myLong = long
        mainMap.clear()
        let camera = GMSCameraPosition.camera(withLatitude:lat, longitude: long, zoom: 11.0)
        mainMap.animate(to: camera)
        mainMap.settings.compassButton = true
        mainMap.settings.zoomGestures = true
        mainMap.settings.myLocationButton = true
        addMyLocationsMarker()
        if campusSelected == campus.Main {
            addNixorMainCampusMarker()
            drawPath(destination: constants.nixorMainCampuslocation, origin: [myLat!,myLong!])
            
        }else{
            addNixorNCFPCampusMarker()
            drawPath(destination: constants.nixorNCFPCampusLocation, origin: [myLat!,myLong!])
        }
    }
    
    
    //Override the location Button
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        locationManager = LocationManager.sharedInstance
        locationManager?.startUpdatingLocationWithCompletionHandler({ (lat, long, status, verbMessage, error) in
            
            if (self.myLat != lat && self.myLong != long && error == nil){
                
                self.initializeMap(lat: lat, long: long)
            } })
        return true
    }
    
    
    //MARK: Add marker for current location.
    func addMyLocationsMarker(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: myLat!, longitude: myLong!)
        marker.title = "Home"
        marker.snippet = "Your location"
       
        
        let MyMarkerImage = UIImageView(image: #imageLiteral(resourceName: "myMarker"))
        var rect = MyMarkerImage.frame
        rect.size.height =  constants.myMarkerIconSize
        rect.size.width = constants.myMarkerIconSize
        MyMarkerImage.frame = rect
        marker.iconView = MyMarkerImage
        
        marker.map =  mainMap
    }
    
    
    
    // Gets selected campus
    func whichCampusIsSelected() -> campus{
        switch campusSelector.selectedSegmentIndex {
        case 0: return campus.Main
        case 1: return campus.NCFP
        default: return campus.Main
        }
    }
    
    //For adding more markers, clear previous ones
    func clearExtraMarkers(){
        mainMap.clear()
        addMyLocationsMarker()
        if whichCampusIsSelected() == campus.Main{
            addNixorMainCampusMarker()
        }else{
            addNixorNCFPCampusMarker()
        }
        
    }
    
    
    
    //MARK: Add marker for nixor main campus
    func addNixorMainCampusMarker(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: constants.nixorMainCampuslocation[0], longitude: constants.nixorMainCampuslocation[1])
        marker.title = "Nixor Main Campus"
        marker.snippet = "Main Campus"
        
        let NixorMarkerImage = UIImageView(image: #imageLiteral(resourceName: "nixorMarker"))
        var rect = NixorMarkerImage.frame
        rect.size.height = constants.nixorMarkerIconSize
        rect.size.width = constants.nixorMarkerIconSize
        NixorMarkerImage.frame = rect
        marker.iconView = NixorMarkerImage
        marker.map =  mainMap
        
    }
    
    
    
    //MARK: Add marker for Nixor NCFP campus
    func addNixorNCFPCampusMarker(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: constants.nixorNCFPCampusLocation[0], longitude: constants.nixorNCFPCampusLocation[1])
        let NixorMarkerImage = UIImageView(image: #imageLiteral(resourceName: "nixorMarker"))
        var rect = NixorMarkerImage.frame
        rect.size.height = constants.nixorMarkerIconSize
        rect.size.width = constants.nixorMarkerIconSize
        NixorMarkerImage.frame = rect
        marker.iconView = NixorMarkerImage
        marker.title = "Nixor NCFP Campus"
        marker.snippet = "NCFP Campus"
        marker.map =  mainMap
        
    }
    
    //On tap add new marker.
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        mainMap.clear()
        
        myLat = coordinate.latitude
        myLong = coordinate.longitude
        addMyLocationsMarker()
        if campusSelected == campus.Main{
            addNixorMainCampusMarker()
            drawPath(destination: constants.nixorMainCampuslocation, origin: [myLat!,myLong!])
        }else{
            addNixorNCFPCampusMarker()
            drawPath(destination: constants.nixorNCFPCampusLocation, origin: [myLat!,myLong!])
        }
        
        
        
        
        
        
    }
    
    //Function to draw route
    func drawPath(destination:[Double], origin:[Double]){
        self.allAvailableRoutes = [routeInformation]()
        self.numberOfRoutes = 0
        
        let origin = "\(origin[0]),\(origin[1])"
        let destination = "\(destination[0]),\(destination[1])"

        let params:[String:Any] = ["destination":destination,"origin":origin,"apikey":delegate.mapAppkey]
        functions.httpsCallable("map_function").call(params) { (response, error) in
    
            if error == nil {
            let routes =   JSON(response?.data)
            self.numberOfRoutes = (routes.array?.count)!
            for indexPath in routes.array!.indices{
           
                let duration = routes[indexPath]["legs"][0]["duration"]["text"].stringValue
                let distance = routes[indexPath]["legs"][0]["distance"]["text"].stringValue
                let start_dest = routes[indexPath]["legs"][0]["start_address"].stringValue
                let end_dest = routes[indexPath]["legs"][0]["end_address"].stringValue
                 self.summary = routes[indexPath]["summary"].stringValue
                let overview_polyline = routes[indexPath]["overview_polyline"]["points"]
                let route = routeInformation(points: overview_polyline, summary: self.summary, distance: distance, duration: duration, end_dest: end_dest, start_dest: start_dest)
                
                self.allAvailableRoutes.append(route)
            }
            if self.numberOfRoutes > 0 {
                self.routesButtons.selectedSegmentIndex = 0
                self.addPolylineRoute(route: self.allAvailableRoutes[0])
                
            }
            
            }else{
                
                self.errorGettingRoutes()
            }
        }

        
   
        
        
    }
    
    func errorGettingRoutes(){}
    
    //Adds route's polyline
    func addPolylineRoute(route:routeInformation){
        
        print("Points: \(route.points.stringValue)")
        myRoute = route.points.stringValue
        let points = route.points
        let path = GMSPath.init(fromEncodedPath: points.stringValue)
        let polyline = GMSPolyline.init(path: path)
        polyline.strokeColor = constants.routeColor
        polyline.strokeWidth = constants.routeWidth
        polyline.map = self.mainMap
      
        setCommuteInformation(duration:route.duration, distance: route.distance, startDest:route.start_dest)
        
    }
    
    
    
    //MARK: Changes selected Campus
    @IBAction func changeCampus(_ sender: UISegmentedControl) {
        
        mainMap.clear()
        switch (sender.selectedSegmentIndex){
        case 0 : campusSelected = campus.Main;
        case 1: campusSelected = campus.NCFP;
        default: break
        }
        addMyLocationsMarker()
        
        if myLat != nil {
            if campusSelected == campus.Main{
                drawPath(destination: constants.nixorMainCampuslocation, origin: [myLat!,myLong!])
            }else{
                drawPath(destination: constants.nixorNCFPCampusLocation, origin: [myLat!,myLong!])
            }
        }
        
        
    }
    
    @IBAction func addSeats(_ sender: UIStepper) {
        
        numberOfSeats = Int(sender.value)
        numberofseats_field.text = "\(numberOfSeats)"
    }
    
    
    func setCommuteInformation(duration:String?, distance:String?, startDest:String?){
        if let totalDuration = duration {
            self.duration = totalDuration
        }
        if var totalDistance = distance{
            let wordToRemove = "km"
            if let range = totalDistance.range(of: wordToRemove) {
                totalDistance.removeSubrange(range)
            }
            print("\(totalDistance)")
            let totalDistance = totalDistance.trimmingCharacters(in: .whitespaces)
            self.distance = Double(totalDistance)
           // print("Distance var: \(self.distance)")
        }
        if let dest = startDest{
            self.startDestination = dest
        }
    }
    
    func setCostPerhead(){
        if let estCost:Double = estimatedCost{
           
                let costPer = estCost / Double(numberOfSeats + 1)
                
                costPerPerson = costPer
           
        }
        
    }
    
    
    func verifyDataIsCorrect() -> Bool{
        if myLat == nil || myLong == nil || myRoute == nil || duration == nil || distance == nil{
            return false
        }
        
        var campusSelec:String?
        if campusSelected == .Main{
            campusSelec = "Main"
        }else{
            campusSelec = "NCFP"
        }
        var startDest = [Double:Double]()
        startDest[myLat!] = myLong!
        
        rideDataFilled = rideData(student_name: initalRideDataFilled!.student_name, student_id: initalRideDataFilled!.student_id, student_number: initalRideDataFilled!.student_number, student_username: initalRideDataFilled!.student_username, privateCarOrTaxi: initalRideDataFilled!.privateCarOrTaxi, iAmtheDriver: initalRideDataFilled!.iAmtheDriver, oneTimeOrScheduled: initalRideDataFilled!.oneTimeOrScheduled, selectedDays: initalRideDataFilled!.selectedDays, selectedTime: initalRideDataFilled!.selectedTime, startDestMyLat: myLat,startDestMyLong: myLong, route: myRoute!, numberOfSeats: numberOfSeats, occupiedSeats: 1, estimatedCost: estimatedCost!, totalDistance: distance!, rideDuration: duration!, mainCampusOrNcfp: campusSelec!,summary:summary,id:"id")
        
        
        return true
        
    }
    func postMyRide(){
        if verifyDataIsCorrect() == true{

            var data = [String:Any]()
            data["student_name"] = rideDataFilled?.student_name
             data["student_id"] = rideDataFilled?.student_id
             data["student_number"] = rideDataFilled?.student_number
             data["student_username"] = rideDataFilled?.student_username
             data["privateCarOrTaxi"] = rideDataFilled?.privateCarOrTaxi
             data["iAmtheDriver"] = rideDataFilled?.iAmtheDriver
             data["oneTimeOrScheduled"] = rideDataFilled?.oneTimeOrScheduled
             data["selectedDays"] = rideDataFilled?.selectedDays
             data["selectedTime"] = rideDataFilled?.selectedTime
             data["myLat"] = rideDataFilled?.startDestMyLat
             data["myLong"] = rideDataFilled?.startDestMyLong
             data["route"] = rideDataFilled?.route
             data["numberOfSeats"] = rideDataFilled?.numberOfSeats
             data["occupiedSeats"] = rideDataFilled?.occupiedSeats
            data["estimatedCost"] = rideDataFilled?.estimatedCost
            data["totalDistance"] = rideDataFilled?.totalDistance
            data["rideDuration"] = rideDataFilled?.rideDuration
            data["mainCampusOrNcfp"] = rideDataFilled?.mainCampusOrNcfp
            data["summary"] = rideDataFilled?.summary
            data["timestamp"] = Timestamp.init()
        
            
            
            
            constants.carpoolDB.addDocument(data: data) { (error) in
                if error == nil {
                    let alertController = UIAlertController(title: "Ride posted", message: constants.carpoolRideBooked, preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                    alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "Ride cannot be posted", message: constants.carpoolRideNotBooked, preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (action) in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            
        }else{
            commonutil.showAlert(title: "Information incomplete", message: "Please make sure all fields are filled.", buttonMessage: "OK", view: self)
            print("Data is incorrect")
        }
    }
    
    //MARK: Changed route
    @IBAction func routeSelected(_ sender: UISegmentedControl) {
        clearExtraMarkers()
        addPolylineRoute(route: allAvailableRoutes[sender.selectedSegmentIndex])
    }
    @IBAction func changeEstimatedCost(_ sender: UITextField) {
        
        
        if let newCost = Double(sender.text!){
            estimatedCost = newCost}
    else{
    if let dist = distance {
    distance_field.text = "\(dist) km"
    let estimatedCost = costPerKM * dist
    estimated_field.text = "\(estimatedCost)"
    self.estimatedCost = estimatedCost
    }}
    
    }
}


struct routeInformation{
    var points:JSON
    var summary:String?
    var distance:String?
    var duration:String?
    var end_dest:String?
    var start_dest:String?
}

enum campus{
    case Main
    case NCFP
    
}


