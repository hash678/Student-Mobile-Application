//
//  home_screen.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
class home_screen: GeneralLayout, UICollectionViewDelegate,UICollectionViewDataSource {
 let Controller = Model()
    var loading = false
        
    
     lazy var functions = Functions.functions()
    var commonutil = common_util()
    var userClass = UserPhoto()
    var username:String?
    var nspButtons = [String]()
    
    @IBOutlet weak var tableview: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nspButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nspCell", for: indexPath) as! nspCell
        cell.name.text = nspButtons[indexPath.row]
        cell.photo.image = getIconForItem(name: nspButtons[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadDocument(name: nspButtons[indexPath.row])
    }
    
    func getIconForItem(name:String)-> UIImage{
        var returnImage = UIImage()
        switch(name){
        case "Profile": returnImage = #imageLiteral(resourceName: "newprofile")
        case "Student Marks": returnImage = #imageLiteral(resourceName: "newstudentmarks")
        case "Gate Attendance": returnImage = #imageLiteral(resourceName: "newgateattendance")
        case "Attendance": returnImage = #imageLiteral(resourceName: "attendance")
        case "Schedule": returnImage = #imageLiteral(resourceName: "newschedule")
        case "TA Log": returnImage = #imageLiteral(resourceName: "talogicon")
        case "TA Schedule": returnImage = #imageLiteral(resourceName: "taicon")
        case "Finance": returnImage = #imageLiteral(resourceName: "newfinance")
        
        default: break
        }
        

        
        return returnImage
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
         initialize()
        
        username = commonutil.getUserData(key: "username")
        commonutil.checkActivation(username: username!, view: self)
        getNspButtons()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        }
    
    
    func loadDocumentFromMemory(name:String) -> URL?{
        let nameOffile = "\(name).pdf"
       // print(nameOffile)
        if let url = self.commonutil.fileExists(name: nameOffile){
          print(url)
            return url
            
        }else{
            dismiss(animated: true, completion: {
                self.commonutil.showAlert(title: "Can't access document", message: "Unable to access document. If the problem persists. Please contact Nixor College ", buttonMessage: "OK", view: self)
            })
            
            return nil
        }
        
    }
    
    func downloadDocument(name:String){
        
        commonutil.showLoading(vc: self, title: "Please wait", message: "") {
            self.loading = true
        }
        
        
        var data = [String:String]()
        data["name"] = name
        data["guid"] = commonutil.getUserData(key: "guid")
        functions.httpsCallable("DocumentAccessFunc").call(data) { (response, error) in
           
            if error != nil {
                
                if let url = self.loadDocumentFromMemory(name: name){
                    self.dismiss(animated: true, completion: {
                          self.commonutil.openPdfViewer(url: url, vc: self)
                    })
                   
                }
                
                
            }else{
            if response != nil{
                let decodedData = Data(base64Encoded: (response?.data as! String))
                let url = decodedData?.write(withName: "\(name).pdf")
              
                if url != nil{
                    self.dismiss(animated: true, completion: {
                        self.commonutil.openPdfViewer(url: url!, vc: self)
                    })
                    
                }else{
                    
                    if let url = self.loadDocumentFromMemory(name: name){
                        self.dismiss(animated: true, completion: {
                            self.commonutil.openPdfViewer(url: url, vc: self)
                        })
                    }
                }
                
            }else
            {
                if let url = self.loadDocumentFromMemory(name: name){
                    self.dismiss(animated: true, completion: {
                        self.commonutil.openPdfViewer(url: url, vc: self)
                    })
                }
                
                }
            }
        }
        
    }
    
    
   

    func getNspButtons(){
        constants.userDB.document(username!).getDocument { (snapshot, error) in
            if snapshot != nil{
                if let value = snapshot!["NspButtons"] {
                    self.nspButtons = value as! [String]
                    self.tableview.reloadData()
                }
                
            }
        }
        
        
    }
    
    
    func initialize(){
     navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        }
        
    
    
    
    
   
    
}
