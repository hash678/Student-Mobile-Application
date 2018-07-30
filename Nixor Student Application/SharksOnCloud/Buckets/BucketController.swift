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
class BucketController{
    let commonUtil = common_util()
    public func sortFilesAndfolders(_ bucketArray:[bucketItem]) -> [bucketItem]{
        var newBucketArray = [bucketItem]()
        for value in bucketArray{
            if value.folder{
                newBucketArray.append(value)
            }
        }
        for value in bucketArray{
            if !value.folder{
                newBucketArray.append(value)
            }
        }
        return newBucketArray
        
    }
    
    func showLoading(vc:UIViewController) -> Bool{
        let alert = UIAlertController(title: "Please wait", message: "Uploading images...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
       
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
        return true
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func createCell(indexPath:IndexPath, bucketItems:[bucketItem], collectionView:UICollectionView) -> uploadedCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadedCell", for: indexPath) as! uploadedCell
        
        
        if !bucketItems[indexPath.row].folder{
        cell.folder = false
            let url = URL(string: bucketItems[indexPath.row].thumnailUrl!)
            cell.thumbnail.kf.setImage(with:url)
            cell.date.text = commonUtil.convertSecondsToDateOnly(interval: bucketItems[indexPath.row].creationDate!)
            cell.points_label.text = "1000 points"
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
    func showImageViewer(images:[LightboxImage],currentpage:Int, vc:UIViewController){
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        //controller.headerView = HeaderView(
        vc.present(controller, animated: true, completion: nil)
        controller.goTo(currentpage)
        
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    
    func showCreateFolder(vc:UIViewController, folderNamesdoc:DocumentReference){
        let alert = UIAlertController(title: "Create folder",
                                      message: "",
                                      preferredStyle: .alert)
        // Submit button
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
             let textField = alert.textFields![0]
            if textField.text != nil {
                if textField.text != ""{
                self.uploadFolder(folderNamesdoc: folderNamesdoc, folderName: textField.text!)
              //  vc.dismiss(animated: true, completion: nil)
                }}
        })
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
       
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter folder name"
            textField.clearButtonMode = .whileEditing
        }
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }
    func showDeletePrompt(indexPath:IndexPath, vc:UIViewController, tableview:UICollectionView,storageRef:StorageReference){
        let alert = UIAlertController(title: "Delete item",
                                      message: "",
                                      preferredStyle: .alert)
        // Submit button
        let submitAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
           
            self.showWarningDelete(indexPath:indexPath, vc:vc, tableview:tableview,storageRef:storageRef)
          
        })
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
          let cell = tableview.cellForItem(at: indexPath) as! uploadedCell
            cell.selectedBool = false
            
        })
        
       
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
        
        
    }
    
    func showWarningDelete(indexPath:IndexPath, vc:UIViewController, tableview:UICollectionView,storageRef:StorageReference){
        
        let alert = UIAlertController(title: "Delete item",
                                      message: "This action cannot be reversed. Are you sure?",
                                      preferredStyle: .alert)
        // Submit button
        let submitAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { (action) -> Void in
            
            
            let cell = tableview.cellForItem(at: indexPath) as! uploadedCell
            cell.selectedBool = false
        })
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            let cell = tableview.cellForItem(at: indexPath) as! uploadedCell
            cell.selectedBool = false
            
        })
        
        
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func deleteItemStorage(vc:UIViewController,documentRef:DocumentReference,storageRef:StorageReference){
       
        documentRef.delete { (error) in
            if error == nil{
            storageRef.delete { (error) in
                
                }}
        }
        
       
            
        
        
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
        
        
        //        private void uploadFolder(final String folderName) {
        //            final Map<String, Object> map = new HashMap<>();
        //
        //            folderNamesdoc.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
        //            @Override
        //            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
        //            if (task.getResult().exists()) {
        //            ArrayList<String> folderNamesList = new ArrayList<>();
        //            folderNamesList = (ArrayList<String>) task.getResult().get("FolderNames");
        //            folderNamesList.add(folderName);
        //            map.put("FolderNames", folderNamesList);
        //            folderNamesdoc.set(map);
        //            } else {
        //            ArrayList<String> folderNamesList = new ArrayList<>();
        //            folderNamesList.add(folderName);
        //            map.put("FolderNames", folderNamesList);
        //            folderNamesdoc.set(map);
        //            }
        //            }
        //
        
    }
    
    
    
}
