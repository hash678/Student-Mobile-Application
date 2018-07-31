//
//  headerImageViewerController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 30/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import Lightbox
protocol headerImageDelegate{
    func downloadImage(controller:LightboxController)
    func shareImage(controller:LightboxController)
}


class headerImageViewerController: UIView {
    
    var delegate:headerImageDelegate?
    @IBOutlet weak var downloadButton: UIButton!
    var imageIndex = 0
    var controller:LightboxController?
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var text_label: UILabel!
    @IBAction func downloadImage(_ sender: Any) {
        delegate?.downloadImage(controller:controller!)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        delegate?.shareImage(controller:controller!)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "headerForImageviewer", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
