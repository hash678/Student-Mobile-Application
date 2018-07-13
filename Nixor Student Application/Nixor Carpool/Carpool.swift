//
//  Carpool.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 09/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import UIKit
class Carpool: UITabBarController {
    override func viewDidLoad() {
        //TODO: Add basic functionality
        initializeView()
         self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.766120717, green: 0.766120717, blue: 0.766120717, alpha: 1)
    }
    
    //Contains all the stuff related to the view.
    func initializeView(){
        // TOP Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
       
        
        //Bottom Tab Bar
   

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //To set Default to middle view controller
    var freshLaunch = true
    override func viewWillAppear(_ animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
      self.selectedViewController = self.viewControllers?[1]
        }}
    
}
