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
    
    
    @IBAction func openMapPopup(_ sender: UIButton) {
        let ShowMapVC = storyboard?.instantiateViewController(withIdentifier: "ShowMap") as! ShowMap
        ShowMapVC.modalPresentationStyle = .overCurrentContext
        ShowMapVC.id = id
        present(ShowMapVC, animated: true, completion: nil)
        
        
    }
    @IBOutlet weak var addMember: UIButton!
    
    @IBAction func confirmRide(_ sender: UIButton) {
    }
    
    @IBAction func cancelRequest(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? Chat, segue.identifier == "chat_details" {
            embeddedVC.id = self.id
        }
    }
   
}
