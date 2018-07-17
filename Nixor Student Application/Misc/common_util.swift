//
//  common_util.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import M13Checkbox
class common_util{
    
    
    public func formatNumber(number: String) -> String{
        print(number.count)
        var formattedNumber:String = number
        if(number.count == "+923342230503".count){
            formattedNumber = String(number.dropFirst(3))
        }else if (number.count == "03432230503".count){
            formattedNumber = String(number.dropFirst(1))
        }else if (number.count == "+12332230503".count){
            formattedNumber = String(number.dropFirst(2))
        }else if (number.count == "8833332230503".count){
            formattedNumber = String(number.dropFirst(3))
        }
        return formattedNumber
    }
    
    //Method to save the StudentDetails struct in in "IOS SharedPref (yes I know.)
    func saveUserData(userObject: StudentDetails){
        if let email = userObject.student_email {
            storeinUserDetails(key: "email", value: email)
            storeinUserDetails(key: "username", value: extractUsername(student_email: email))
        }
        
        if let name = userObject.student_name {
            storeinUserDetails(key: "name", value: name)
        }
        
        if let student_id = userObject.student_id {
            storeinUserDetails(key: "student_id", value: student_id)
        }
        
        if let nsp_photo = userObject.student_profileUrl {
            storeinUserDetails(key: "nsp_photo", value: nsp_photo)
        }
        if let guid = userObject.student_guid {
            storeinUserDetails(key: "guid", value: guid)
        }
    }
    
    //Simple method to skip the rubbish syntax, used to store values in "IOS SharedPref (yes I know.)"
    func storeinUserDetails(key: String, value: String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    //Method to extract Username from user's email address
    func extractUsername(student_email:String) -> String{
        var sentence = student_email
        let wordToRemove = "@nixorcollege.edu.pk"
        if let range = sentence.range(of: wordToRemove) {
            sentence.removeSubrange(range)
        }
        sentence = sentence.replacingOccurrences(of: ".", with: "-")
        return sentence
    }
    
    
    //Method to convert Firebase document to StudentDetails Struct
    public func documentToStudentObject(firebaseDocument: DocumentSnapshot) -> StudentDetails{
        var student:StudentDetails = StudentDetails()
        
        if let email = firebaseDocument.get("student_email"){
            student.student_email = email as? String
           
        }
        
        if let house = firebaseDocument.get("student_house"){
            student.student_house = house as? String
        }
        
        if let year = firebaseDocument.get("student_year"){
            student.student_year = year as? String
        }
        
        if let id = firebaseDocument.get("student_id"){
            student.student_id = id as? String
        }
        
        if let name = firebaseDocument.get("student_name"){
            student.student_name = name as? String
        }
        
        //NSP PHOTO NOT FIREBASE FOR FIREBASE USE "photourl"
        if let nsp_photo = firebaseDocument.get("student_profileUrl"){
            student.student_profileUrl = nsp_photo as? String
        }
        
        if let guid = firebaseDocument.get("student_guid"){
            student.student_guid = guid as? String
        }
        print("Student Details: \(student)")
        return student
    }
    
    //    public String extractUsername(Context context, String email){
    //    String domain = context.getString(R.string.domain_textView);
    //    return  email.replaceAll(domain,"").replace(".","-");
    //    }
   
    public func getUserData(key: String) -> String?{
        return UserDefaults.standard.string(forKey: key)
    }
    
    public func loadImageViewURLFirebase(url: String, imageview:UIImageView){
        let url = URL(string: url)
        imageview.kf.setImage(with: url)
        
        //        let storageRef = Storage.storage().reference(forURL: url)
//        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//            let pic = UIImage(data: data!)
//                imageview.image = pic
//        }
//
//    }
}
    
   
}

extension UIImageView{
     func circleImage(){
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
    }
}
extension UIView{
    //cell.view.layer.shadowColor = UIColor.black.cgColor
   

    func giveMeShadowsBitch(){
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.5;
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension M13Checkbox{
    func isChecked() -> Bool{
        if self.checkState == CheckState.checked{
            return true
        }else{
            return false
        }}
}
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
extension Dictionary{
    func checkIfAlValuesFalse() -> Bool{
        
        
        for key in self.indices{
      
                let value = self[key].value as! Bool
                if value == true{
                    return false
                }
            
            
        }
        return true
    }
    
}

/*
How accessible is it?

 How deep are you nesting it?
 pushID?
 .document().
 
 Users -> Bucket -> pujksdbkasjbsakjImage -> url
 Users -> Bucket -> pujksdbkasjbsakjImage-> metaData["Date","Type","size"] -> smallData ->
 
Repetition matters when you have update data
Why?
 You have to update at multiple locations. IF I MISS OUT ON ANY 1
 
Anything that can be, is or will be useful.
 
 */
extension UIView {
    
    func setCardView(){
       let view = self
        view.layer.cornerRadius = 5.0
        view.layer.borderColor  =  UIColor.clear.cgColor
        view.layer.borderWidth = 5.0
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor =  UIColor.lightGray.cgColor
        view.layer.shadowRadius = 5.0
        view.layer.shadowOffset = CGSize(width:5, height: 5)
        view.layer.masksToBounds = true
        
    }
}
