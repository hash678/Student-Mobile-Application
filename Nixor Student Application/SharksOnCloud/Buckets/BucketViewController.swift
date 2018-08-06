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
import FirebaseRemoteConfig

class BucketViewController: GeneralLayout, UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,GalleryControllerDelegate,UIGestureRecognizerDelegate, headerImageDelegate,LightboxControllerPageDelegate{
    
    
    
    
    var username:String?
    let commonUtil = common_util()
    var folderNames = [String]()
    var bucketItems = [bucketItem]()
    var imageID = [String]()
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableview: UICollectionView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    var class_type:String?
    var selectedSubject:String?
    var uploadCount = 0
    let thumbnailSize:CGFloat = 200
    let photoSize:CGFloat = 800
    let maxImageCount = 30
    let Controller = Model()
    var showingLoading = false
    var folderNamesdoc:DocumentReference?
    var foldersdoc:DocumentReference?
    var folderCount = 0
    let maxNumberFolders = 10
    var firebaseUploadCount = 0 {
        didSet{
            if self.uploadCount == self.firebaseUploadCount{
                
            }
        }
    }
    
    var thumnailURL = [String:String]()
    var photoURL = [String:String]()
    var uploadDoneCount = 0 {
        didSet{
            if self.uploadDoneCount == self.uploadCount{
                self.uploadCount = self.uploadCount / 2
                uploadDoneCount = 0
                self.saveToFireStore()
            }
        }
    }
    var storageReference:StorageReference?
    var myUploadsCollection:CollectionReference?
    var lightboxController:LightboxController?
    var bucketUser:String?
    var myBucket = false
    var folderName:String?
    var subscribed = false {
        didSet {
             subscribeButton.isHidden = false
            if !subscribed{
                subscribeButton.setImage(#imageLiteral(resourceName: "subscribeButton"), for: .normal)
            }else{
                subscribeButton.setImage(#imageLiteral(resourceName: "unSubscribeButton"), for: .normal)
            }
        }
    }
    
    
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        let totalItems = bucketItems.count - folderNames.count
        
        let view = self.Controller.setHeaderView(currentPage: page, totalImages: totalItems, delegate: self, controller: controller)
        let oldView = controller.footerView.subviews[controller.footerView.subviews.count - 1]
        oldView.removeFromSuperview()
        controller.footerView.addSubview(view)
        view.bindFrameToSuperviewBounds()
    }
    
    
    
    
    func downloadImage(controller:LightboxController) {
        let index = controller.currentPage + folderNames.count
        let urlString = bucketItems[index].photourl
        let url = URL(string: urlString!)
        self.Controller.downloadImage(url: url!) { (image) in
            self.lightboxController = controller
            self.saveImage(image: image)
            
        }
        
        
        
    }
    
    private func saveImage(image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let ac = UIAlertAction(title: "OK", style: .default)
        if let error = error {
            //ERROR
            commonUtil.showAlert(vc: lightboxController!, title: "Save error", message: error.localizedDescription, buttons: [ac]) { (alert) in
                
            }
            
        } else {
            //SUCCESS
            commonUtil.showAlert(vc: lightboxController!, title: "Saved!", message: "The screenshot has been saved to your photos.", buttons: [ac]) { (alert) in
                
            }
            
        }
    }
    
    
    
    
    
    func shareImage(controller:LightboxController) {
        let index = controller.currentPage + folderNames.count
        let urlString = bucketItems[index].photourl
        let url = URL(string: urlString!)
        self.Controller.downloadImage(url: url!) { (image) in
            let imageToShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            controller.present(activityViewController, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        dismiss(animated: true) {
            self.commonUtil.showLoading(vc: self, title: "Please wait", message: "") {
                self.showingLoading = true
            }
        }
        self.uploadCount = images.count * 2
        for image in images {
            image.resolve { (uiImage) in
                
                if uiImage != nil{
                    let resizedImage =
                        uiImage!.scaleImage(scaledToWidth: self.photoSize)
                    let thumnailResized = uiImage!.scaleImage(scaledToWidth: self.thumbnailSize)
                    
                    
                    let compressed = resizedImage.jpeg(UIImage.JPEGQuality.low)
                    let compressedThumnail = thumnailResized.jpeg(UIImage.JPEGQuality.low)
                    let documentName = Database.database().reference().child("SOCIDS").childByAutoId().key
                    
                    self.uploadImageToFirebase(documentName:documentName, image: compressed!, bucketUser: self.bucketUser!,thumnail: false)
                    self.uploadImageToFirebase(documentName:documentName,image: compressedThumnail!, bucketUser: self.bucketUser!,thumnail: true)
                }else{
                    self.uploadCount -= 2
                }
            }}}
    
    
    private func saveToFireStore(){
        var userInfo = [String:String]()
        userInfo["className"] = "101"
        userInfo["student_name"] = commonUtil.getUserData(key: "name")
       // myUploadsCollection!.setData(userInfo)
        
        let batch = Firestore.firestore().batch()
        for keys in photoURL.keys{
            let documetRef = myUploadsCollection!.document(keys)
            let data = self.storeToFirestore(name: keys, type: "Image", PhotoUrlImageViewver: photoURL[keys]!, PhotoUrlThumbnail: thumnailURL[keys]!)
            batch.setData(data, forDocument: documetRef)
        }
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                if self.showingLoading {
                    self.dismiss(animated: false, completion: nil)
                    self.showingLoading = false
                    self.tableview.reloadData()
                    print("Batch write succeeded.")
                }}}}
    
    
    
    
    private func storeToFirestore(name:String,type:String,PhotoUrlImageViewver:String,PhotoUrlThumbnail:String) -> [String:Any]{
        var dic = [String:Any]()
        dic["Name"] = name
        dic["Type"] = type
        dic["PhotoUrlImageViewver"] = PhotoUrlImageViewver
        dic["PhotoUrlThumbnail"] = PhotoUrlThumbnail
        dic["Date"] = Timestamp.init().seconds
        dic["Points"] = 0
        
        
        
        return dic
        
        
    }
    
    
    
    
    func errorHandling (){
        print("Error Occurred while Uploading")
        
        uploadCount -= 1
    }
    
    private func uploadImageToFirebase(documentName:String, image: Data, bucketUser: String, thumnail:Bool){
        
        let key = Database.database().reference().child("SOCIDS").childByAutoId().key
        let photoURLRef = storageReference!.child("\(key).jpg")
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
          
        }
    }
    
    
    
    @IBAction func create(_ sender: Any) {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        let photos = UIAlertAction(title: "Upload Photo", style: .default, handler: {
            (alert: UIAlertAction) in
            self.chooseMedia()
        })
        
        let clearBucket = UIAlertAction(title: "Delete All Items", style: .destructive, handler: {
            (alert: UIAlertAction) in
            
            self.Controller.showDeletePrompt(vc: self, title: "Delete All Items?", method: {
                self.deleteFiles()
            })
        })
        
        
        
        let createFolder = UIAlertAction(title: "Create Folder", style: .default, handler: {
            (alert: UIAlertAction) in
            if self.folderNamesdoc != nil{
                self.Controller.showCreateFolder(vc: self, folderNamesdoc: self.folderNamesdoc!)}
            
        })
        
        
        if folderCount <= maxNumberFolders{
        
            commonUtil.showAlertAction(vc: self, title: "", message: "Manage Bucket", buttons: [photos,createFolder,clearBucket,cancel]) { (alert) in
                
            }
            
        }else{
            commonUtil.showAlertAction(vc: self, title: "", message: "Manage Bucket", buttons: [photos,clearBucket,cancel]) { (alert) in
                
            }
        }
        
    }
    
    
    private func chooseMedia(){
        Config.tabsToShow =  [.imageTab, .cameraTab]
        Config.Camera.imageLimit = maxImageCount
        let imagePickerController = GalleryController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    
    private func getAllUploadedImages(){
        let myDocumentRef =  myUploadsCollection!
        self.Controller.getUploadedImages(documentRef: myDocumentRef) { (myImageId, myBucketItems, myfolderNames) in
            print(myfolderNames)
            self.imageID = myImageId
            self.folderNames = myfolderNames
            self.bucketItems = myBucketItems
            self.bucketItems = self.Controller.sortFilesAndfolders(self.bucketItems)
            self.tableview.reloadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = commonUtil.getUserData(key: "username")
        setMyReferences()
        myBucket = username == bucketUser ? true : false
        addButton.isHidden = myBucket ? false : true
        subscribeButton.isHidden = true
        
        
        self.title = folderName !=  nil ? folderName : (myBucket ? "My Bucket" : bucketUser)
       
        if !myBucket{
            checkIfSubscribed()}
        self.hideKeyboardWhenTappedAround()
        getAllUploadedImages()
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.tableview?.addGestureRecognizer(lpgr)
        
    }
    
    
    
   
    
    
    func setMyReferences(){
        let storage = Storage.storage()
        let storageRef = storage.reference();
        storageReference = storageRef.child("SOC").child(class_type!).child(selectedSubject!).child(bucketUser!)
        
        if myUploadsCollection != nil{
             myUploadsCollection = myUploadsCollection!.document(folderName!).collection("Buckets")
        }else{
        myUploadsCollection = Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(bucketUser!).collection("Buckets")
        }
        
        folderNamesdoc = myUploadsCollection!.document("Folder Names")
        foldersdoc = myUploadsCollection!.document("Folders")
    }
    
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.tableview)
        let indexPath : IndexPath = (self.tableview?.indexPathForItem(at: p))! as IndexPath
        let cell = tableview.cellForItem(at: indexPath) as! uploadedCell
        cell.selectedBool = true
        
        self.Controller.showDeletePrompt(vc: self,title:"Delete Item?") {
            
            self.deleteSelectedFile(index: indexPath.row)
            cell.selectedBool = false
        }
        
        
    }
    
    
    
    
    
    
    
    //Functions For deleting files and folders
    func deleteSelectedFile(index:Int){
        let name = bucketItems[index].imageName
        let documentRef =  myUploadsCollection!.document(name!)
        
        
        
        let storagetrefPhoto = storageReference!.child("\(bucketItems[index].photourl!).jpg")
        let storageRefThumb = storageReference!.child("\(bucketItems[index].thumnailUrl!).jpg")
        
        Controller.deleteItemStorage(vc: self, documentRef: documentRef, storageRefPhoto: storagetrefPhoto, storageRefThumb: storageRefThumb)
        
        
    }
    func deleteFiles(){
        
        for index in self.bucketItems.indices{
            if !self.bucketItems[index].folder && self.bucketItems.count > 0{
                
                let name = self.bucketItems[index].imageName
                let documentRef = myUploadsCollection!.document(name!)
                
                
                
                let storagetrefPhoto = storageReference!.child("\(self.bucketItems[index].photourl!).jpg")
                
                let storageRefThumb = storageReference!.child("\(self.bucketItems[index].thumnailUrl!).jpg")
                
                self.Controller.deleteItemStorage(vc: self, documentRef: documentRef, storageRefPhoto: storagetrefPhoto, storageRefThumb: storageRefThumb)
                
            }}
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
            Controller.showImageViewer(images: Controller.imageObject(urlArray: bucketItems), currentpage: (indexPath.item - folderNames.count), vc:self,delegate: self,changePage:self)
        }else{
            
            let Folders = storyboard?.instantiateViewController(withIdentifier: "BucketViewController") as! BucketViewController
     
            Folders.class_type = class_type
            Folders.folderName = self.folderNames[indexPath.row]
            Folders.selectedSubject = selectedSubject
            Folders.bucketUser = bucketUser
            Folders.myUploadsCollection = myUploadsCollection
            Folders.folderCount = self.folderCount + 1
          self.navigationController?.pushViewController(Folders, animated: true)
            
            
            
        }
        
    }
    //CollectionView Methods
   
    func checkIfSubscribed(){
        
            let collectionRef =  Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(bucketUser!).collection("Buckets")
        
        Controller.checkIfSubscribed(username: username!, collectionref: collectionRef) { (subscribed) in
           
           self.subscribed = subscribed
        }
        
    }
 
    @IBAction func subscribeToBucket(_ sender: UIButton) {
      subscribeButton.isHidden = true
        let collectionRef =  Firestore.firestore().collection("SharksOnCloud").document(class_type!).collection("Subjects").document(selectedSubject!).collection("Users").document(bucketUser!).collection("Buckets")
        Controller.subscribeToBucket(username: username!, collectionRef: collectionRef, subscribe:!subscribed) {
            self.subscribed = !self.subscribed
            let toastMessage = self.subscribed ? "Subscribed" : "Unsubscribed "
            self.showToast(message: toastMessage)
           
        }
    }
    
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
