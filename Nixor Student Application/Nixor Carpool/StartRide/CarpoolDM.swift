//
//  CarpoolDM.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 17/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit

class CarpoolDM: UIViewController{
    @IBOutlet weak var chat: UIView!
    var id:String?
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? Chat, segue.identifier == "chat_details" {
            embeddedVC.id = self.id
        }
    }
   
}
