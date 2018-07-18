//
//  LoginController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 17/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CountryPickerView
class LoginController: UIViewController {

    var phoneNumberVar:String?
    @IBOutlet weak var phoneNumberEntry: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    var credential:PhoneAuthCredential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.setCountryByCode("PK")
        self.dismissKeyboard()
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
        checkAuth()
    }

    
    func checkAuth(){
        if  Auth.auth().currentUser != nil{
             self.userSignedIn()
            
        }
    }
    
    func sendCodePhone(phoneNumber:String){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                self.commonutil.showAlert(title: "Couldn't send code", message: error.localizedDescription, buttonMessage: "OK", view: self)
                
                return
            }else{
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let NavigationController =  self.storyboard?.instantiateViewController(withIdentifier: "VerifyCode") as! VerifyCode
                NavigationController.verification = verificationID
                self.navigationController?.pushViewController(NavigationController, animated: true)
            }
           
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func sendCode(_ sender: UIButton) {
        if let phoneNumber = phoneNumberEntry.text {
            print(countryPicker.selectedCountry)
          phoneNumberVar = countryPicker.selectedCountry.phoneCode+phoneNumber
            sendCodePhone(phoneNumber: phoneNumberVar!)
        }
    
    
    }
    
    func checkIfUserDataExists(userPhoneNumber: String){
        Firestore.firestore().collection("account_link").document(userPhoneNumber).getDocument { (document, error) in
            if error == nil{
                //print("Document: \(document) ")
                //Account exists, NSP DATA AVAILABLE
                var accountType = accountTypeGetSet()
                accountType.mode = document?.get("mode") as? String
                accountType.username = document?.get("username") as? String
                if let username = accountType.username, let type = accountType.mode{
                    self.checkAccountType(whatmode: type, username: username)}
            }else{
                //Account doesn't exist. NSP DATA MISSING
                //TODO: NSP LOGIN
                
            }
            
        }}
    
    //Check's to see account type and process accordingly. Also saves the user data to IOS SharedPref (Deal with it :p)
    func checkAccountType(whatmode mode: String, username: String){
        let db = Firestore.firestore()
        db.collection("users").document(username).getDocument { (document, error) in
            if error == nil{
                if  let documentObtained = document{
                    let student = self.commonutil.documentToStudentObject(firebaseDocument: documentObtained)
                    self.commonutil.saveUserData(userObject: student)
                    self.intentToNextViewController()
                }}
        }
    }
    var phoneNumber:String?
    public func userSignedIn(){
        
        print("Signed in user")
        self.phoneNumber = commonutil.formatNumber(number: (Auth.auth().currentUser?.phoneNumber)!)
        
        self.checkIfUserDataExists(userPhoneNumber: self.phoneNumber!)
        
    }
    
    
    func intentToNextViewController(){
        let NavigationController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! NavigationController
        present(NavigationController, animated: true, completion:nil)
    }
  
}
