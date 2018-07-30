//
//  MyBucketViewController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 24/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import Gallery
import FirebaseStorage
import FirebaseFirestore
import Lightbox
import FirebaseDatabase
class MyBucketViewController: UIViewController, UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,GalleryControllerDelegate,UIGestureRecognizerDelegate{
    
    
    var username:String?
    let commonUtil = common_util()
    var folderNames = [String]()
    var bucketItems = [bucketItem]()
    var imageID = [String]()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableview: UICollectionView!
    let imagePickerController = GalleryController()
    var class_type:String?
    var selectedSubject:String?
    var uploadCount = 0
    let thumbnailSize:CGFloat = 200
    let photoSize:CGFloat = 800
    let Controller = BucketController()
    var showingLoading = false
     var folderNamesdoc:DocumentReference?
    var foldersdoc:DocumentReference?
    var firebaseUploadCount = 0 {
        didSet{
            if self.uploadCount == self.firebaseUploadCount{
                if self.showingLoading {
                    print("Values equal")
                    
                    self.dismiss(animated: false, completion: nil)
                    showingLoading = false
                }
            }
        }
    }
    
    var thumnailURL = [String:String]()
    var photoURL = [String:String]()
    var uploadDoneCount = 0 {
        didSet{
            if self.uploadDoneCount == self.uploadCount{
                self.uploadCount = self.uploadCount / 2
                self.saveToFireStore()
            }
        }
    }
    
    
    
 
    func storeToFirestore(name:String,type:String,PhotoUrlImageViewver:String,PhotoUrlThumbnail:String){
        var dic = [String:Any]()
        dic["Name"] = name
        dic["Type"] = type
        dic["PhotoUrlImageViewver"] = PhotoUrlImageViewver
        dic["PhotoUrlThumbnail"] = PhotoUrlThumbnail
        dic["Date"] = Timestamp.init().seconds
      
        
        var userInfo = [String:String]()
        userInfo["className"] = "101"
        userInfo["student_name"] = commonUtil.getUserData(key: "name")
        Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(username!).setData(userInfo)
        
        
        Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(username!).collection("Buckets").document(name).setData(dic) { (error) in
            if error == nil{
                self.firebaseUploadCount += 1
            }
        }

    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
          dismiss(animated: true, completion: nil)
        showingLoading = Controller.showLoading(vc:self)
      self.uploadCount = images.count * 2
        for image in images {
            image.resolve { (uiImage) in
              
                let resizedImage = self.Controller.imageWithImage(sourceImage: uiImage!, scaledToWidth: self.photoSize)
                let thumnailResized = self.Controller.imageWithImage(sourceImage: uiImage!, scaledToWidth: self.thumbnailSize)

             let compressed = resizedImage.jpeg(UIImage.JPEGQuality.low)
            let compressedThumnail = thumnailResized.jpeg(UIImage.JPEGQuality.low)
               let documentName = Database.database().reference().child("SOCIDS").childByAutoId().key
                
                self.uploadImageToFirebase(documentName:documentName, image: compressed!, username: self.username!,thumnail: false)
                self.uploadImageToFirebase(documentName:documentName,image: compressedThumnail!, username: self.username!,thumnail: true)

            }
            
        }
        
        
        
    }
    
    func saveToFireStore(){
        for keys in photoURL.keys{
           // print(photoURL)
            //print(thumnailURL)
          storeToFirestore(name: keys, type: "Image", PhotoUrlImageViewver: photoURL[keys]!, PhotoUrlThumbnail: thumnailURL[keys]!)
            
        }
        
        
        
        
    }
    

    
    
    

    func errorHandling (){}
 
    private func uploadImageToFirebase(documentName:String, image: Data, username: String, thumnail:Bool){
        let storage = Storage.storage()
        let storageRef = storage.reference();
        let key = Database.database().reference().child("SOCIDS").childByAutoId().key
        let photoURLRef = storageRef.child("SOC").child(class_type!).child(selectedSubject!).child(username).child("\(key).jpg")
        let _ = photoURLRef.putData(image, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                print("Couldn't get meta data")
                self.errorHandling()
                return
               
            }
            photoURLRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error ?? "No error yayy!!")
                   self.errorHandling()
                    return
                }
           
                if thumnail{
                    self.thumnailURL[documentName] = "\(downloadURL)"
                }else{
                    self.photoURL[documentName] = "\(downloadURL)"
                }
                
                self.uploadDoneCount += 1
               
                print("UPLOAD COUNT \(self.uploadCount) UPLOAD DONE COUNT \(self.uploadDoneCount)")
            }
            
           // let size = metadata.size
           // print("Size is \(size)")
         }
    }
    
  

    @IBAction func create(_ sender: Any) {
        let alert =  UIAlertController(title: "", message: "Manage Bucket", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        let photos = UIAlertAction(title: "Upload Photo", style: .default, handler: {
            (alert: UIAlertAction) in
            self.chooseMedia()
        })
        
        let clearBucket = UIAlertAction(title: "Delete All Items", style: .destructive, handler: {
            (alert: UIAlertAction) in
         //Clear bucket
        })
        
        let createFolder = UIAlertAction(title: "Create Folder", style: .default, handler: {
            (alert: UIAlertAction) in
            if self.folderNamesdoc != nil{
                self.Controller.showCreateFolder(vc: self, folderNamesdoc: self.folderNamesdoc!)}

        })
        alert.addAction(photos)
        alert.addAction(cancel)
        alert.addAction(createFolder)
        alert.addAction(clearBucket)
        present(alert, animated:true, completion: nil)
    }
    
    
    private func chooseMedia(){
        Config.tabsToShow =  [.imageTab, .cameraTab]
       present(imagePickerController, animated: true, completion: nil)
       
    }
    
    
    
    
    //MARK: Method to load images from Firebase.
    func getAllUploadedImages(){
        
        var ref:CollectionReference?
        switch class_type{
        case "AS": ref = constants.sharksOnCloudSubjectsAs
        case "A2": ref = constants.sharksOnCloudSubjectsA2
        default:break;
        }
        ref?.document(selectedSubject!).collection("Users").document(username!).collection("Buckets").order(by: "Date", descending: true)
            .addSnapshotListener({ (Query, error) in
                
                if Query != nil{
                    self.imageID = [String]()
                    self.bucketItems = [bucketItem]()
                    self.folderNames = [String]()
                    
                    for documents in (Query?.documents)!{
                        
                        //For files
                        if documents.documentID != "Folder Names"{
                            print("Not folder \(documents.documentID)")
                            if let name = documents["Name"] as? String ,
                                let photourl = documents["PhotoUrlImageViewver"] as? String,
                                let date = documents["Date"] as? Double,
                                let PhotoUrlThumbnail = documents["PhotoUrlThumbnail"] as? String{
                                let item = bucketItem(imageName: name, creationDate: date, points: nil, thumnailUrl: PhotoUrlThumbnail , photourl: photourl,folder:false)
                                
                                
                                
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
   
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        username = commonUtil.getUserData(key: "username")
        addButton.circleImage()
        imagePickerController.delegate = self
        getAllUploadedImages()
        folderNamesdoc = Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(username!).collection("Buckets").document("Folder Names")
        
        foldersdoc = Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(username!).collection("Buckets").document("Folders")
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.tableview?.addGestureRecognizer(lpgr)
        
       
    }
    
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.tableview)
        
        if let indexPath : IndexPath = (self.tableview?.indexPathForItem(at: p))! as IndexPath{
            //do whatever you need to do
            let cell = tableview.cellForItem(at: indexPath) as! uploadedCell
            cell.selectedBool = true
            //Controller.showDeletePrompt(indexPath: indexPath, vc: self, tableview: self.tableview,storageRef: )
            
        }
        
    }
    
    
    
    
    
    
    //CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return Controller.createCell(indexPath: indexPath, bucketItems: self.bucketItems,collectionView:tableview)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !bucketItems[indexPath.row].folder{
        Controller.showImageViewer(images: Controller.imageObject(urlArray: bucketItems), currentpage: (indexPath.item - folderNames.count), vc:self)
    }
    
}
    
    
    //CollectionView Methods
    
 
    
    

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
