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
class studentBucker: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,headerImageDelegate,LightboxControllerPageDelegate {
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        let totalItems = bucketItems.count - folderNames.count
        
        let view = self.Controller.setHeaderView(currentPage: page, totalImages: totalItems, delegate: self, controller: controller)
        let oldView = controller.footerView.subviews[controller.footerView.subviews.count - 1]
        oldView.removeFromSuperview()
        controller.footerView.addSubview(view)
        view.bindFrameToSuperviewBounds()
    }
  
    var lightboxController:LightboxController?
    let commonUtil = common_util()
    
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

    
    //MARK: Method to load images from Firebase.
    func getAllUploadedImages(){
        
        var ref:CollectionReference?
        switch class_type{
        case "AS": ref = constants.sharksOnCloudSubjectsAs
        case "A2": ref = constants.sharksOnCloudSubjectsA2
        default:break;
        }
       
        let myDocumentRef = ref?.document(selectedSubject!).collection("Users").document(userBucket!)
        self.Controller.getUploadedImages(documentRef: myDocumentRef!) { (myImageId, myBucketItems, myfolderNames) in
            
            print(myfolderNames)
            self.imageID = myImageId
            self.folderNames = myfolderNames
            self.bucketItems = myBucketItems
            self.bucketItems = self.Controller.sortFilesAndfolders(self.bucketItems)
            self.tableview.reloadData()
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
            Controller.showImageViewer(images: Controller.imageObject(urlArray: bucketItems), currentpage: (indexPath.item - folderNames.count), vc:self,delegate: self,changePage:self)
        }
        
    }
    
    
    //CollectionView Methods
    

}
