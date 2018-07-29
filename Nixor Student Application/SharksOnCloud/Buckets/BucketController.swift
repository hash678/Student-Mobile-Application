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
import Lightbox
class BucketController{
    
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
        let loadingBar = UILoading
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
            let url = URL(string: bucketItems[indexPath.row].thumnailUrl!)
            cell.thumbnail.kf.setImage(with:url)
            
        }else{
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
    
    
    
}
