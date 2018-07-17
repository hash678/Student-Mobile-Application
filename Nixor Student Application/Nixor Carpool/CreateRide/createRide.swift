//
//  createRide.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 11/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
import M13Checkbox
import FirebaseAuth
class createRide: UIViewController{
    
    @IBOutlet weak var days: UIStackView!
    @IBOutlet weak var monday: M13Checkbox!
    @IBOutlet weak var tuesday: M13Checkbox!
    @IBOutlet weak var wednesday: M13Checkbox!
    @IBOutlet weak var thursday: M13Checkbox!
    @IBOutlet weak var friday: M13Checkbox!
    @IBOutlet weak var saturday: M13Checkbox!
    @IBOutlet weak var sunday: M13Checkbox!
    @IBOutlet weak var student_photo: UIImageView!
    @IBOutlet weak var privateOrTaxi: UISegmentedControl!
    @IBOutlet weak var driverPrivateCar: UISegmentedControl!
    @IBOutlet weak var student_number: UITextField!
    @IBOutlet weak var student_id: UILabel!
    @IBOutlet weak var student_name: UILabel!
    @IBOutlet weak var pickerDateAndTime: UIDatePicker!
    
    @IBOutlet weak var iamtheDriverView: UIView!
    @IBOutlet weak var daysView: UIView!
    
    let commonutil = common_util()
    let userClass = UserPhoto()
    
    var selectedDays = [String:Bool]()
    var username:String?
    var studentName:String?
    var studentID:String?
   
    var userNumber:String?
    var privateCarOrTaxiSelected = privateCarOrTaxi.taxi
    var initalride:initalRideData?
    var ride_type = rideType.once{
        didSet{
            switch(ride_type){
            case .scheduled:pickerDateAndTime.datePickerMode = UIDatePickerMode.time; days.isHidden = false;
            daysView.isHidden = false;pickerDateAndTime.minuteInterval = 15;
            case .once: pickerDateAndTime.datePickerMode = UIDatePickerMode.dateAndTime; days.isHidden = true; pickerDateAndTime.minimumDate =  Date().tomorrow
              daysView.isHidden = true;pickerDateAndTime.minuteInterval = 15;
            }
        }
        
    }

  
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        userNumber = commonutil.formatNumber(number: (Auth.auth().currentUser?.phoneNumber)!)
        intializeView()
        getMyData()
    }
   
    
    //MARK: Function to get userData from SharedPrefs
    func getMyData(){
        
        student_photo.circleImage()
        if let username_local = commonutil.getUserData(key: "username"){
            userClass.getMyPhoto(username: username_local, imageview: student_photo!)
            username = username_local
        }
        if let name = commonutil.getUserData(key: "name"){
            student_name.text = name
            studentName = name
        }
        
        if let studentid = commonutil.getUserData(key: "student_id"){
            student_id.text = studentid
            studentID = studentid
        }
        
        student_number.placeholder = userNumber
        student_name.text = studentName
        student_id.text = studentID
    }
    
    //Get Selected days
    //Dictionary -> HASHMAP
    func setSelectedDays(){
        selectedDays["Monday"] = monday.isChecked()
        selectedDays["Tuesday"] = tuesday.isChecked()
        selectedDays["Wednesday"] = wednesday.isChecked()
        selectedDays["Thursday"] = thursday.isChecked()
        selectedDays["Friday"] = friday.isChecked()
        selectedDays["Saturday"] = saturday.isChecked()
        selectedDays["Sunday"] = sunday.isChecked()
    }
    
    //Change ride type
    @IBAction func changeType(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 1: ride_type = rideType.scheduled;
        case 0: ride_type = rideType.once;
        default:break
        }
        
    }
    
    //Verify's data and creates initalRide data
    func verifyDataIsCorrect() -> Bool {

        switch privateOrTaxi.selectedSegmentIndex{
        case 0: privateCarOrTaxiSelected = privateCarOrTaxi.taxi
        case 1:privateCarOrTaxiSelected = privateCarOrTaxi.privateCar
        default: break
            
        }
        
        if ride_type == rideType.scheduled{
            setSelectedDays()
            if selectedDays.checkIfAlValuesFalse(){
                return false
            }
        }
      let selectedTime = pickerDateAndTime.date.timeIntervalSince1970
        var iAmtheDriver:Bool?
        if privateCarOrTaxiSelected == .privateCar{
            switch driverPrivateCar.selectedSegmentIndex{
            case 0: iAmtheDriver = true
            case 1: iAmtheDriver = false
            default: break
            }
        }
        let rideisoftype:String?
        if ride_type == .once{
            rideisoftype = "once"
        }else{
            rideisoftype = "scheduled"
        }
        let privatecarortaxiIsit:String?
        if privateCarOrTaxiSelected == .taxi{
            privatecarortaxiIsit = "taxi"
        }else{
            privatecarortaxiIsit = "privateCar"
        }
        if username != nil, studentName != nil, studentID != nil{
       initalride = initalRideData(student_name: studentName!, student_id: studentID!, student_number: userNumber, student_username: username, privateCarOrTaxi: privatecarortaxiIsit, iAmtheDriver: iAmtheDriver, oneTimeOrScheduled: rideisoftype, selectedDays: selectedDays, selectedTime: selectedTime)
        }else{
            return false
        }
        return true
    }
    
    //MARK: Design method to make time picker look better
    func initializeDateTimePicker(){
        pickerDateAndTime.setValue(UIColor.white, forKey: "textColor")
        pickerDateAndTime.subviews[0].subviews[1].backgroundColor = #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
        pickerDateAndTime.subviews[0].subviews[2].backgroundColor = #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
        pickerDateAndTime.backgroundColor = #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
        let currentDate = Date().tomorrow
        pickerDateAndTime.setDate(currentDate, animated: true)
    }
    
    //MARK: Change taxi or private car
    @IBAction func taxiOrPrivateCar(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0: driverPrivateCar.isHidden = true; iamtheDriverView.isHidden = true;
        case 1: driverPrivateCar.isHidden = false; iamtheDriverView.isHidden = false;
        default: break
        }
    }
    //MARK: Back button functionality
    @objc func back(sender: UIBarButtonItem) {
        dismiss(animated: true, completion:nil)
    }
    //MARK: Next button
    //TODO: Add transfer of object
    @objc func next(sender: UIBarButtonItem) {
        if verifyDataIsCorrect() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mapViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! mapViewController
            mapViewController.initalRideDataFilled = self.initalride
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }else{
            let alertController = UIAlertController(title: "Information incomplete", message: "Please make sure all fields are filled.", preferredStyle: .alert)
        
            let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,  handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            // Add the actions
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            print("Data is incorrect")
        }
        
   
    }
    
   
    //MARK: Just all the viewDidload's design initializations
    func intializeView(){
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(createRide.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let newNextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(createRide.next(sender:)))
        self.navigationItem.rightBarButtonItem = newNextButton
        self.dismissKeyboard()
        initializeDateTimePicker()
        
    }
    
    
    
    
    
    
}
//OUTSIDE OF CLASS
enum rideType{
    case scheduled
    case once
}
enum privateCarOrTaxi{
    case privateCar
    case taxi
    
}




