//
//  NspLogin.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 20/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseFunctions
import JASON
class NspLogin: UIViewController {

    @IBOutlet weak var email_field: UITextField!
    lazy var functions = Functions.functions()
    let commonUtil = common_util();
    
    
    @IBOutlet weak var password_field: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: UIButton) {
   
        if let email = email_field.text, let password = password_field.text {
            let username = email.replacingOccurrences(of: ".", with: "-")
            let data = ["email":"\(email)@nixorcollege.edu.pk","password":password,"username":username]
            print("\(email)@nixorcollege.edu.pk")
            print(password)
            print(username)
            
            functions.httpsCallable("NSP_EXTRACTION_FUNCTION").call(data) { (response, error) in
                if response != nil {
                    print(JSON(response?.data))
                    let jsonObject = JSON(response?.data)
                    
                    let studentDetails = StudentDetails(jsonObject: jsonObject)
                    self.commonUtil.saveUserData(userObject: studentDetails)
                   
                    let SelectAccountType = self.storyboard?.instantiateViewController(withIdentifier: "SelectAccountType") as! SelectAccountType
                    self.present(SelectAccountType, animated: true, completion:nil)
                    
                    
                    
                }else if error != nil{
                 //   print(error)
                }
            }
            
        }
    
    }
    

}
