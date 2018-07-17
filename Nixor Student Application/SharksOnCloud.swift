//
//  SharksOnCloud.swift
//  
//
//  Created by Hassan Abbasi on 08/07/2018.
//

import UIKit

class SharksOnCloud: UIViewController, MyHeaderDelegate {
    @IBOutlet weak var header: headerMain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        header.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onBackPressed() {
        dismiss(animated: true, completion: nil)
    }
    

   
}
