//
//  VerifyCode.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 17/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import PinCodeTextField
import FirebaseAuth
import Firebase
class VerifyCode: GeneralLayout {
    var verification:String?
    var number:String?
    
    @IBOutlet weak var codeEntry: PinCodeTextField!
    @IBOutlet weak var verifyCode: UIButton!
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    var credential:PhoneAuthCredential?
    var handler:LoginHandler?
    
    @IBOutlet weak var phoneNumber: UILabel!
    
    
    func signIn(credential:PhoneAuthCredential){
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
               
                self.commonutil.showAlert(title: "Verification failed", message: error.localizedDescription, buttonMessage: "OK", view: self)
                return
            }else{
                print("Code verified")
                self.handler?.userSignedIn()
            }
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handler = LoginHandler(view: self)
         self.hideKeyboardWhenTappedAround()
        self.codeEntry.keyboardType = UIKeyboardType.phonePad
        navigationController?.title = "Verify phone number"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
       phoneNumber.text = number
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VerifyCode.back(sender:)))
          let nextButton = UIBarButtonItem(title: "Verify", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VerifyCode.sendCode(sender:)))
        self.navigationItem.rightBarButtonItem = nextButton
        self.navigationItem.leftBarButtonItem = newBackButton

        
        
    }
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
    }
    @objc func sendCode(sender: UIBarButtonItem) {
        
        if let code = codeEntry.text, verification != nil {
            credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verification!,
                verificationCode: code)
            signIn(credential: credential!)
        }
        
    }
   



}
