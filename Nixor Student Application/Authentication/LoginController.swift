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
class LoginController: GeneralLayout , CountryPickerViewDelegate, CountryPickerViewDataSource  {

    @IBOutlet weak var selectedCountryCode: UITextField!
    var phoneNumberVar:String?
    @IBOutlet weak var phoneNumberEntry: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    var credential:PhoneAuthCredential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.setCountryByCode("PK")
        countryPicker.delegate = self
        countryPicker.dataSource = self
        self.hideKeyboardWhenTappedAround()
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
                NavigationController.number = phoneNumber
                self.navigationController?.pushViewController(NavigationController, animated: true)
            }
           
        }
    }
    
    @IBAction func sendCode(_ sender: UIBarButtonItem) {
        if let phoneNumber = phoneNumberEntry.text {
            print(countryPicker.selectedCountry)
            phoneNumberVar = countryPicker.selectedCountry.phoneCode+phoneNumber
            sendCodePhone(phoneNumber: phoneNumberVar!)
        }
        
    }
    
  
 
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        selectedCountryCode.text = country.phoneCode
    }
  
  
}
