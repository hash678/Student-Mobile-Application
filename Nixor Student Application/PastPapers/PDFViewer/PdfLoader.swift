//
//  PdfLoader.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 07/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import WebKit
class PdfLoader: UIViewController {
    public var url: URL?
    
    @IBOutlet weak var web: WKWebView!
    @IBAction func backButton(_ sender: Any) {
   dismiss(animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(url)
        web.loadFileURL(url!, allowingReadAccessTo: url!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
