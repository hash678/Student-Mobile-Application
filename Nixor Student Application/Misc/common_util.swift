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
    public func circleImage(image: UIImageView?) -> UIImageView?{
        image?.layer.cornerRadius = 25
        image?.layer.masksToBounds = true
        return image
    }
    public func getUserData(key: String) -> String?{
        return UserDefaults.standard.string(forKey: key)
    }
    
    public func loadImageViewURLFirebase(url: String, imageview:UIImageView){
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            let pic = UIImage(data: data!)
                imageview.image = pic
        }
        
    }
    
    
    
}
