//
//  User.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 05/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
class UserPhoto{
    var commonutil = common_util()
    
    private  func uploadImageToFirebase(image: Data, username: String, imageview:UIImageView){
        let storage = Storage.storage()
        let storageRef = storage.reference();
        let photoURLRef = storageRef.child("display_photo/\(username)/dp.jpg")
        let uploadTask = photoURLRef.putData(image, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Couldn't get meta data")
                return
            }
            photoURLRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error)
                    return
                }
            
                Firestore.firestore().collection("users").document(username).setData(["photourl" : downloadURL.absoluteString])
               self.setDisplay(imageview: imageview, profileurl: downloadURL.absoluteString)
                print(downloadURL)
            }
            
            let size = metadata.size
            print("Size is \(size)")
            
        }
    }
    
    
    public func downloadImageAndSaveToFirebase(url: URL, username: String, imageview:UIImageView) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let NSData = UIImageJPEGRepresentation(UIImage(data: data)!, 0.025)
                    self?.uploadImageToFirebase(image: NSData!, username: username,imageview: imageview)
                }}}}
    
    private func checkIfPhotoIntialized(username: String, imageview:UIImageView){
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            if document != nil {
                if let profileUrl = document?.get("photourl") as? String {
                     self.commonutil.storeinUserDetails(key: "profileurl", value: profileUrl)
                    self.setDisplay(imageview: imageview, profileurl: profileUrl)
                    print("Got profile url")
                }else{
                    if let url_string = self.commonutil.getUserData(key: "nsp_photo"){
                        if let url = URL(string: url_string){
                            self.downloadImageAndSaveToFirebase(url: url, username: username, imageview: imageview)}}
                }
                
            }}
    }
    
    private func setDisplay(imageview:UIImageView, profileurl:String){
       print("ProfileUrl: \(profileurl)")
        let storageRef = Storage.storage().reference(forURL: profileurl)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            let pic = UIImage(data: data!)
            imageview.image = pic
        }}
    public func getMyPhoto(username:String, imageview:UIImageView){
        if let profilurl = commonutil.getUserData(key: "photourl"){
            //Set Display
            setDisplay(imageview: imageview, profileurl: profilurl)
        }else{
            checkIfPhotoIntialized(username: username, imageview: imageview)
        }
        
    }
    
    
}


