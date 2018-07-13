//
//  headerMain.swift
//  
//
//  Created by Hassan Abbasi on 08/07/2018.
//

import UIKit


@objc protocol MyHeaderDelegate{
    @objc optional func onBackPressed()
}


class headerMain: UIView {
    
    var delegate:MyHeaderDelegate?
let commonutil = common_util()
    let userClass = UserPhoto()
   

    @IBOutlet weak var student_id: UILabel!
    @IBOutlet weak var student_name: UILabel!
    @IBOutlet weak var student_photo: UIImageView!
    @IBOutlet var contentView: UIView!
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit(){
    Bundle.main.loadNibNamed("header",owner: self,options:nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setMYData()
    }
    
    func setMYData(){
        student_photo.circleImage()
        if let username_local = commonutil.getUserData(key: "username"){
            userClass.getMyPhoto(username: username_local, imageview: student_photo!)
           
        }
        if let name = commonutil.getUserData(key: "name"){
            student_name.text = name
            
        }
        
        if let studentid = commonutil.getUserData(key: "student_id"){
            student_id.text = studentid
            
        }
    }
    
}
