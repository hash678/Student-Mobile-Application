
//
//  Buckets.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 19/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit

class Buckets: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "bucketsTableViewCell") as! bucketsTableViewCell
       
  
        
        
        cell.view.setCardView()
        cell.student_photo.circleImage()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         tableview.tableFooterView = UIView()
        tableview.rowHeight = 65

    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}
