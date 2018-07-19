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
    
    
   
    @IBAction func sendCode(_ sender: UIButton) {
        if let phoneNumber = phoneNumberEntry.text {
            print(countryPicker.selectedCountry)
          phoneNumberVar = countryPicker.selectedCountry.phoneCode+phoneNumber
            sendCodePhone(phoneNumber: phoneNumberVar!)
        }
    
    
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
 
  
  
}
