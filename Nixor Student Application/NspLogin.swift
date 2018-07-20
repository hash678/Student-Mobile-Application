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
    
    @IBOutlet weak var password_field: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: UIButton) {
   
        if let email = email_field.text, let password = password_field.text {
            
//            const email=data['email'];
//            const password=data['password'];
//            const username=data['username'];
//
//            Functions.httpsCallable(<#T##Functions#>)
            
            let username = email.replacingOccurrences(of: ".", with: "-")
            let data = ["email":"\(email)@nixorcollege.edu.pk","password":password,"username":username]
            print("\(email)@nixorcollege.edu.pk")
            print(password)
            print(username)
            
            functions.httpsCallable("NSP_EXTRACTION_FUNCTION").call(data) { (response, error) in
                if response != nil {
                    print(JSON(response?.data))
                }else{
                    print(error)
                }
            }
            
        }
    
    }
    

}
