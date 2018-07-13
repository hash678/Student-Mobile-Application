import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Login: UIViewController {
    let username = "hassan@gmail.com"
    let password = "123456"
    var LoggedInUser:AuthDataResult?
    var commonutil = common_util()
    var phoneNumber: String?
    public var userPhonenumber = "3332230503"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // here is an entry point into our app
       if Auth.auth().currentUser == nil {
            self.signInUserTemp()
            
        }else{
           userSignedIn()
        }
      }
    
    func intialize(){}
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

    
    //A trash method I am using. I will replace this with the proper implementation once my developer account is set up
    //TODO: add phone auth
    func signInUserTemp(){
        Auth.auth().signIn(withEmail: username, password: password) {
            (user, error) in
            if user != nil {
                self.userSignedIn()
            }else {
                if let myError = error?.localizedDescription {
                    print(myError)
                }else{
                    print("Error")
                }
            }
        }
    }
    
    public func userSignedIn(){
       
        print("Signed in user")
        self.phoneNumber = UserDefaults.standard.string(forKey: "phone_number")
        if self.phoneNumber == nil{
            self.commonutil.storeinUserDetails(key: "phone_number", value: self.userPhonenumber)
            self.phoneNumber = UserDefaults.standard.string(forKey: "phone_number")
        }
        self.checkIfUserDataExists(userPhoneNumber: self.phoneNumber!)
        print("Phone Number is: \(self.phoneNumber!)")
    }
    
   
    func intentToNextViewController(){
     let NavigationController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! NavigationController
        present(NavigationController, animated: true, completion:nil)
    }
}



    
    
 



