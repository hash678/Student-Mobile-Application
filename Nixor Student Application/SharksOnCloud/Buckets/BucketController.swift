//
//  BucketController.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 29/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
import Lightbox
import Firebase
import Kingfisher
class BucketController{
    let commonUtil = common_util()
  
    
    
    public func sortFilesAndfolders(_ bucketArray:[bucketItem]) -> [bucketItem]{
        
        return  (commonUtil.sortFiles(array: bucketArray) { (value) -> Bool in
            if let item = value as? bucketItem{
                if item.folder{
                    return true
                }
            }
            return false
        }) as! [bucketItem]
  
 
    }

   
    func dateForSoc(interval:Double) -> String{
        
        let date = Date(timeIntervalSince1970: interval)
        
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MMMM/yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: date)
        
        
        return dateString
        
        
        
        
    }
    
    
    func showLoading(vc:UIViewController) -> Bool{
        return commonUtil.showLoading(vc: vc, title: "Please wait", message: "Uploading images")
    }
    
    
    func createCell(indexPath:IndexPath, bucketItems:[bucketItem], collectionView:UICollectionView) -> uploadedCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadedCell", for: indexPath) as! uploadedCell
        
        
        if !bucketItems[indexPath.row].folder{
            cell.folder = false
            let url = URL(string: bucketItems[indexPath.row].thumnailUrl!)
            cell.thumbnail.kf.setImage(with:url)
            cell.date.text = dateForSoc(interval: bucketItems[indexPath.row].creationDate!)
            
            if let points = bucketItems[indexPath.row].points{
                cell.points_label.text = "\(points) points"
                
            }else{
                
                cell.points_label.text = "\(0) points"
            }
        }else{
            cell.date.text = bucketItems[indexPath.row].imageName
            cell.points_label.isHidden = true
            cell.thumbnail.image = #imageLiteral(resourceName: "folderIcon")
            
        }
        return cell
        
    }
    
    //MARK:Generates arraylist of lightBox images
    func imageObject(urlArray:[bucketItem])-> [LightboxImage]{
        var lightboxImages = [LightboxImage]();
        for urls in urlArray{
            if !urls.folder{
                
                lightboxImages.append(LightboxImage(imageURL: URL(string: urls.photourl!)!))}
        }
        return lightboxImages
        
    }
    
    //MARK: Imageviewe
    func showImageViewer(images:[LightboxImage],currentpage:Int, vc:UIViewController, delegate:headerImageDelegate,changePage:LightboxControllerPageDelegate){
        let controller = LightboxController(images: images)
        //controller.dynamicBackground = true
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        customView.backgroundColor = #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(#imageLiteral(resourceName: "heartIcon"), for: .normal)
     
       
        if let _ = vc as? MyBucketViewController{
        }else{
            controller.headerView.addSubview(customView)
        }
        
       controller.pageDelegate = changePage
      
        let view = setHeaderView(currentPage: currentpage, totalImages: images.count, delegate: delegate,controller: controller)
        controller.footerView.addSubview(view)
        view.bindFrameToSuperviewBounds()
        vc.present(controller, animated: true, completion: nil)
        controller.goTo(currentpage)
        
    }
    
    func setHeaderView(currentPage:Int,totalImages:Int,delegate:headerImageDelegate, controller:LightboxController) -> UIView{
        let view = headerImageViewerController.instanceFromNib() as! headerImageViewerController
        view.delegate = delegate
        view.imageIndex = currentPage
        view.controller = controller
        view.text_label.text = "\(currentPage + 1) of \(totalImages + 1)"
        
        return view
    }
    
    
    func showCreateFolder(vc:UIViewController, folderNamesdoc:DocumentReference){
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        commonUtil.showAlert(vc: vc, title: "Create folder", message: "", buttons: [cancel]) { (alert) in
            alert.addTextField { (textField: UITextField) in
                textField.keyboardAppearance = .dark
                textField.keyboardType = .default
                textField.autocorrectionType = .default
                textField.placeholder = "Enter folder name"
                textField.clearButtonMode = .whileEditing
                let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                    
                    let textField = alert.textFields![0]
                    if textField.text != nil {
                        if textField.text != ""{
                            self.uploadFolder(folderNamesdoc: folderNamesdoc, folderName: textField.text!)
                        }}
                })
                alert.addAction(submitAction)
                
            }}
        
    }
    
    
    
    
    func showDeletePrompt(vc:UIViewController,title:String,method:@escaping () -> Void){
        let submitAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            self.showWarningDelete(vc: vc,title:title, method: {
                method()
            })
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        commonUtil.showAlert(vc: vc, title: title, message: "", buttons: [submitAction,cancel]) { (alert) in
            
        }
        
    }
    
    private func showWarningDelete(vc:UIViewController,title:String,method:@escaping () -> Void){
        let submitAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { (action) -> Void in
            method()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        commonUtil.showAlert(vc: vc, title: title, message: "This action cannot be reversed. Are you sure?",buttons: [submitAction,cancel]) { (alert) in
            
        }
        
    }
    
    
    func deleteItemStorage(vc:UIViewController,documentRef:DocumentReference,storageRefPhoto:StorageReference,storageRefThumb:StorageReference){
        
        documentRef.delete { (error) in
            if error == nil{
                storageRefPhoto.delete { (error) in
                    storageRefThumb.delete { (error) in
                        
                    }}
            }}
    }
    
    
    
    
    
    
    
    
    
    func uploadFolder(folderNamesdoc:DocumentReference,folderName:String){
        
        var data = [String:Any]()
        folderNamesdoc.getDocument { (snapshot, error) in
            var currentFolders = [String]()
            if snapshot?.data() != nil{
                currentFolders = snapshot!.data()!["FolderNames"] as! [String]
                currentFolders.append(folderName)
                
            }else{
                currentFolders.append(folderName)
            }
            data["FolderNames"] = currentFolders
            data["Date"] = Timestamp.init().seconds
            folderNamesdoc.setData(data)
            
            
        }
        
        
        
    }
    
    func getUploadedImages(documentRef:DocumentReference, onComplete:@escaping ([String],[bucketItem],[String]) -> Void){
        var imageID = [String]()
        var bucketItems = [bucketItem]()
        var folderNames = [String]()
        documentRef.collection("Buckets").order(by: "Date", descending: true)
            .addSnapshotListener({ (Query, error) in
                if Query != nil{
                    imageID = [String]()
                    bucketItems = [bucketItem]()
                    folderNames = [String]()
                    
                    
                    for documents in (Query?.documents)!{
                        //For files
                        if documents.documentID != "Folder Names"{
                            print("Not folder \(documents.documentID)")
                            let points =  documents["Points"] as? Int
                            
                            if let name = documents["Name"] as? String ,
                                let photourl = documents["PhotoUrlImageViewver"] as? String,
                                let date = documents["Date"] as? Double,
                                let PhotoUrlThumbnail = documents["PhotoUrlThumbnail"] as? String{
                                let item = bucketItem(imageName: name, creationDate: date, points: points, thumnailUrl: PhotoUrlThumbnail , photourl: photourl,folder:false)
                                if !imageID.contains(documents.documentID){
                                    bucketItems.append(item)
                                    imageID.append(documents.documentID)
                                }}
                        }else{
                            print("Folder \(documents.data())")
                            let folderArray = documents.data()
                            if let folders = folderArray["FolderNames"] as? [String]{
                                for folderName in folders{
                                    let item = bucketItem(imageName: folderName, creationDate: nil, points: nil, thumnailUrl: nil , photourl: nil,folder:true)
                                    if !folderNames.contains(folderName){
                                        bucketItems.append(item)
                                        folderNames.append(folderName)
                                                print("folderNames : \(folderNames)")
                                    }}
                            }}
                    }
                   
                    onComplete(imageID,bucketItems,folderNames)
                }
                
            })
        
    }
    
    
    func downloadImage(url:URL,method:@escaping (UIImage) -> Void){
        ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
            (image, error, url, data) in
            method(image!)
           
        }
    }
   
    
    
    
}


