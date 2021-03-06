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
import FirebaseDatabase
import M13Checkbox
import NVActivityIndicatorView
class common_util{
    
    
    func sortFiles(array:[Any],priorityItem:(Any) -> Bool) -> [Any]{
        var sortedArray = [Any]()
        
        for index in array{
            if priorityItem(index){
                sortedArray.append(index)
            }
        }
        
        for index in array{
            if !priorityItem(index){
                sortedArray.append(index)
            }
        }
        
        
        
        return sortedArray
    }
    
    func NewfilterObjects(text:String,exclude:[String] ,check:(String) -> Bool) -> Bool{
        
        let excludedWords = exclude.capitalizeArray() as! [String]
        let constraint = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var firstsplit = constraint.split(separator: " ")
        
        var count = 0
        var found = 0
        for index in firstsplit.indices{
            let value = firstsplit[index].trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            
            if(!excludedWords.contains(value)){
                count += 1
            }else{
                count += 1
                found += 1
            }
            
            let contains = check(value)
            if contains {
                found += 1}}
        if found == count {
            return true
            
        }
        return false
        
        
        
    }
    
    
    
    func showAlertAction(vc:UIViewController,title:String,message:String,buttons:[UIAlertAction],extra:(UIAlertController) -> Void){
        
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for button in buttons {
            alert.addAction(button)
        }
        
          extra(alert)
        vc.present(alert, animated:true, completion: nil)
    }
    
    
    func showAlert(vc:UIViewController,title:String,message:String,buttons:[UIAlertAction],extra:(UIAlertController) -> Void){
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        for button in buttons{
            alert.addAction(button)
        }
        extra(alert)
        
        vc.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
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
    
    
    
    
    
    
  
    
    
    func convertSecondsToDateOnly(interval:Double) -> String{
        
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInYesterday(date) {
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
           // let dateString = formatter.string(from: date)
           
            
            return "Yesterday"
            
            
            
        }
        else if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
           // let dateString = formatter.string(from: date)
            return "Today"
        
        }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "MMMM dd, yyyy"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            return "\(dateString)"
            
        }
    }
    
    
    func convertSecondsToDate(interval:Double) -> String{
        
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInYesterday(date) {
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            
            
            return "Yesterday, \(dateString)"
            
            
            
        }
        else if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            return dateString
            
        }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: date)
            return dateString
            
        }
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
    
 
    
    //Search Objects
    func itContains(value:String,object:Any) -> Bool{
        let mirror = Mirror(reflecting: object)
        for values in mirror.children{
            if let text = values.value as? String{
                if text.contains(value){
                    return true}
                }}
        return false
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
        
        if let email = firebaseDocument.get("studentEmail"){
            student.student_email = email as? String
           
        }
        
        if let house = firebaseDocument.get("studentHouse"){
            student.student_house = house as? String
        }
        
        if let year = firebaseDocument.get("studentYear"){
            student.student_year = year as? String
        }
        
        if let id = firebaseDocument.get("studentID"){
            student.student_id = id as? String
        }
        
        if let name = firebaseDocument.get("studentName"){
            student.student_name = name as? String
        }
        
        //NSP PHOTO NOT FIREBASE FOR FIREBASE USE "photourl"
        if let nsp_photo = firebaseDocument.get("student_profileUrl"){
            student.student_profileUrl = nsp_photo as? String
        }
        
        if let guid = firebaseDocument.get("GUID"){
            student.student_guid = guid as? String
        }
        print("Student Details: \(student)")
        return student
    }
    
    
    
    func checkActivation(username:String,view:UIViewController){
        Database.database().reference().child("activated").observe(.value) { (snapshot) in
            if  let value = snapshot.value as? NSDictionary{
                if value["all"] == nil{
                    if value[username] == nil{
                    
                let alertController = UIAlertController(title: "Account not activated", message: "It seems like your account is not activated. Please contact Nixor Administration. Thank you", preferredStyle: .alert)
                
               
                
                // Present the controller
                        view.present(alertController, animated: true, completion: nil)}
            }
                
            }else{
                let alertController = UIAlertController(title: "Account not activated", message: "It seems like your account is not activated. Please contact Nixor Administration. Thank you", preferredStyle: .alert)
                
                
                
                // Present the controller
                view.present(alertController, animated: true, completion: nil)}
                
            }
        }

    func fileExists(name:String) -> URL?{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(name)
        if  FileManager().fileExists(atPath: localURL.path){
            return localURL
        }
        return nil
        
    }
    
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func showLoading(vc:UIViewController,title:String,message:String,complete:@escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        
        let loadingIndicator = NVActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50), type: NVActivityIndicatorType.ballScale, color: #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1), padding: nil)
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true) {
            complete()
            
        }
   
    }
    
    
    
    func showAlert(title:String,message:String,buttonMessage:String,view:UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: buttonMessage, style: UIAlertActionStyle.default,  handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        // Add the actions
        alertController.addAction(cancelAction)
        
        // Present the controller
        view.present(alertController, animated: true, completion: nil)
        
       
    }
    func openPdfViewer(url:URL, vc:UIViewController){
        
        let storyboard = UIStoryboard(name: "PastpapersStoryboard", bundle: nil)
        let singleView = storyboard.instantiateViewController(withIdentifier: "pdfIntent") as! PdfLoader
        singleView.url = url
        vc.present(singleView,animated: true, completion: nil)
    }
    public func getUserData(key: String) -> String?{
        return UserDefaults.standard.string(forKey: key)
    }
    
    public func loadImageViewURLFirebase(url: String, imageview:UIImageView){
      
        imageview.setImage(url: url)
       
}
    
   
}

extension UIView{
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


extension UIView{
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unbindToKeyboard(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    @objc
    func keyboardWillChange(notification: Notification) {
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0.0)

    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    func scaleImage (scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = self.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
extension UIImageView{
    func setImage(url:String){
        let url = URL(string: url)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)

    }
    func setImage(url:URL){
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)
    }
}

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
extension Data {
    
    func write(withName name: String) -> URL {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent(name)
        try! write(to: url, options: .atomic)
        
        return url
    }
    
   
}


extension UIView {
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 50).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        
    }
}

extension Array{
    func capitalizeArray() -> [Any]{
        if var array = self as? [String]{
            for index in array.indices{
                array[index] = array[index].localizedCapitalized
                
            }
            return array
            
        }
        return self
    }
    
}


