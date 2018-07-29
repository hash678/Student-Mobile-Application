//
//  studentBucker.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 24/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Lightbox
class studentBucker: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {

    var bucketItems = [bucketItem]()
    var imageID = [String]()
    var selectedSubject:String?
    var class_type:String?
    var userBucket:String?
    var folderNames = [String]()
    let Controller = BucketController()
    @IBOutlet weak var tableview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getAllUploadedImages()
    }

    
    //MARK: Get data from firebase
    func getAllUploadedImages(){
        var ref:CollectionReference?
        switch class_type{
        case "AS": ref = constants.sharksOnCloudSubjectsAs
        case "A2": ref = constants.sharksOnCloudSubjectsA2
        default:break;
        }
        ref?.document(selectedSubject!).collection("Users").document(userBucket!).collection("Buckets")
            .addSnapshotListener({ (Query, error) in
          
            if Query != nil{
                
                for documents in (Query?.documents)!{
                    
                    //For files
                    if documents.documentID != "Folder Names"{
                    print("Not folder \(documents.documentID)")
                    if let name = documents["Name"] as? String ,
                        let photourl = documents["PhotoUrlImageViewver"] as? String,
                        let PhotoUrlThumbnail = documents["PhotoUrlThumbnail"] as? String{
                        let item = bucketItem(imageName: name, creationDate: nil, points: nil, thumnailUrl: PhotoUrlThumbnail , photourl: photourl,folder:false)
                        
                      
                        
                        if !self.imageID.contains(documents.documentID){
                            self.bucketItems.append(item)
                            self.imageID.append(documents.documentID)
                        
                        }
                    
                    
                    }
                    
                    }else{
                         print("Folder \(documents.data())")
                        let folderArray = documents.data()
                            if let folders = folderArray["FolderNames"] as? [String]{
                                for folderName in folders{
                                let item = bucketItem(imageName: folderName, creationDate: nil, points: nil, thumnailUrl: nil , photourl: nil,folder:true)
                            if !self.folderNames.contains(folderName){
                                self.bucketItems.append(item)
                                self.folderNames.append(folderName)
                                
                                    }}
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                }
                self.bucketItems = self.Controller.sortFilesAndfolders(self.bucketItems)
                self.tableview.reloadData()
            }
            
        })
        
    }
    

    
    //CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return Controller.createCell(indexPath: indexPath, bucketItems: self.bucketItems,collectionView:collectionView)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Controller.showImageViewer(images: Controller.imageObject(urlArray: bucketItems), currentpage: indexPath.item, vc:self)
    }
    //CollectionView Methods
    
    

}
