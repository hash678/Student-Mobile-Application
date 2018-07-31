//
//  pdfMultiView.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 07/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import WebKit
class pdfMultiView: GeneralLayout {

    
    public var firstPaper:URL?
    public var secondPaper:URL?
    var translation: CGPoint!
    var startPosition: CGPoint! //Start position for the gesture transition
    var originalHeight: CGFloat = 0 // Initial Height for the UIView
    var difference: CGFloat!
  
    @IBOutlet weak var topWebView: WKWebView!
    
    @IBOutlet weak var bottomWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        originalHeight = dragView.frame.height
        topWebView.loadFileURL(firstPaper!, allowingReadAccessTo: firstPaper!)
        bottomWebView.loadFileURL(secondPaper!, allowingReadAccessTo: secondPaper!)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var dragView: UIView! //Above View
    
    @IBOutlet weak var aboveView: UIView!
    
    @IBOutlet weak var belowView: UIView!
    
    @IBOutlet var gestureRecognizer: UIPanGestureRecognizer!
    
    @IBAction func viewDidDragged(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            startPosition = gestureRecognizer.location(in: dragView) // the postion at which PanGestue Started
        }
     
        if (sender.state == .began || sender.state == .changed){
           
            
            
            let endPosition = sender.location(in: dragView) // the posiion at which PanGesture Ended
            difference = endPosition.y - startPosition.y
                   var belowFrame = belowView.frame
                var newFrame = dragView.frame
              var aboveFrame = aboveView.frame
            if (difference > 0 && belowFrame.height > 50) || (difference < 0 && aboveFrame.height > 50 ){
                translation = sender.translation(in: self.view)
                // sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self.view)
               
            newFrame.origin.x = dragView.frame.origin.x
            newFrame.origin.y = dragView.frame.origin.y + difference //Gesture Moving Upward will produce a negative value for difference
            newFrame.size.width = dragView.frame.size.width
            newFrame.size.height = dragView.frame.size.height - difference //Gesture Moving Upward will produce a negative value for difference
            dragView.frame = newFrame
            
            
     
            belowFrame.origin.x = belowView.frame.origin.x
            belowFrame.origin.y = belowView.frame.origin.y + difference //Gesture Moving Upward will produce a negative value for difference
            belowFrame.size.width = belowView.frame.size.width
            belowFrame.size.height = belowView.frame.size.height - difference //Gesture Moving Upward will produce a negative value for difference
            belowView.frame = belowFrame
            
            
          
            aboveFrame.origin.x = aboveView.frame.origin.x
            //aboveFrame.origin.y = //Gesture Moving Upward will produce a negative value for difference
            aboveView.center.y = aboveView.frame.origin.y - difference
            aboveFrame.size.width = aboveView.frame.size.width
            aboveFrame.size.height = aboveView.frame.size.height + difference //Gesture Moving Upward will produce a negative value for difference
            aboveView.frame = aboveFrame
        }
        }
        if sender.state == .ended || sender.state == .cancelled {
            //Do Something
        }
    }
    
  
    
 
    @IBAction func onBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   
}


