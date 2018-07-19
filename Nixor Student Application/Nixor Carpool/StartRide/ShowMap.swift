//
//  ShowMap.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 18/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
class ShowMap: UIViewController, GMSMapViewDelegate {

    var id:String?
    @IBOutlet weak var map: GMSMapView!
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       map.delegate = self
        if id != nil{
            getRideInformation(id:id!)}
    }
    
    func getRideInformation(id:String){
        constants.carpoolDB.document(id).getDocument { (document, error) in
            if error == nil{
                let mapInformation = document!.data()
                let myLat = mapInformation!["myLat"] as! Double
                let myLong = mapInformation!["myLong"] as! Double
                let route = mapInformation!["route"] as! String
                let mainCampusOrNcfp = mapInformation!["mainCampusOrNcfp"] as! String
                
                self.setMap(startDestMyLat: myLat, startDestMyLong: myLong, mainCampusOrNcfp: mainCampusOrNcfp, route: route)
                
            }
        }
    }

    func setMap(startDestMyLat:Double, startDestMyLong:Double,mainCampusOrNcfp:String,route:String){
        map.clear()
        let camera = GMSCameraPosition.camera(withLatitude:startDestMyLat, longitude: startDestMyLong, zoom: 12.0)
        map.animate(to: camera)
        map.settings.compassButton = true
       map.settings.zoomGestures = true
       map.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: startDestMyLat, longitude: startDestMyLong)
        let MyMarkerImage = UIImageView(image: #imageLiteral(resourceName: "myMarker"))
        var rect = MyMarkerImage.frame
        rect.size.height = constants.myMarkerIconSize
        rect.size.width = constants.myMarkerIconSize
        MyMarkerImage.frame = rect
        marker.iconView = MyMarkerImage
        marker.map =  map
        
        var nixorLat:Double?
        var nixorLong:Double?
        
        if mainCampusOrNcfp == "Main"{
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
        Nixormarker.map =  map
        
        let points = route
        let path = GMSPath.init(fromEncodedPath: points)
        let polyline = GMSPolyline.init(path: path)
        polyline.strokeColor = constants.routeColor
        polyline.strokeWidth = constants.routeWidth
        polyline.map = map
    }
    
    

}
