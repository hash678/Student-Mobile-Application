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
                self.userSignedIn()
            }
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.dismissKeyboard()
        navigationController?.title = "Login"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
        // Do any additional setup after loading the view.
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

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }


}
