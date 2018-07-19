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
class VerifyCode: UIViewController {
    var verification:String?
    @IBOutlet weak var codeEntry: PinCodeTextField!
    @IBOutlet weak var verifyCode: UIButton!
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    var credential:PhoneAuthCredential?
    var handler:LoginHandler?
    
    @IBAction func verifyCode(_ sender: UIButton) {
        
        if let code = codeEntry.text, verification != nil {
          credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verification!,
                verificationCode: code)
            signIn(credential: credential!)
        }
        
        
    }
    
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
         self.dismissKeyboard()
        self.codeEntry.keyboardType = UIKeyboardType.phonePad
        navigationController?.title = "Login"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
        // Do any additional setup after loading the view.
    }
    
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }




}
