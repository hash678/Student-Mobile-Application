//
//  SideBarViewController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 31/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit

class SideBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Do any additional setup after loading the view.
    }

    


}
