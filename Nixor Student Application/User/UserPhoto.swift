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
class UserPhoto{
    private var commonutil = common_util()
    
    
    //TODO: Add Tags check for wrapping and unwrapping add a bit of exception handling and then move to pastpapers. See you tomorrow babe ❤️
    
    //Method to upload downloaded image from NSP site to firebase storage and save it's ref and the load it. (I know I used two ands )
    private  func uploadImageToFirebase(image: Data, username: String, imageview:UIImageView){
        let storage = Storage.storage()
        let storageRef = storage.reference();
        let photoURLRef = storageRef.child("display_photo/\(username)/dp.jpg")
        let _ = photoURLRef.putData(image, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Couldn't get meta data")
                return
            }
            photoURLRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error ?? "No error yayy!!")
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
    
    //Even though the name sames download and save this only downloads the image and then passes it to the other method
    private func downloadImageAndSaveToFirebase(url: URL, username: String, imageview:UIImageView) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let NSData = UIImageJPEGRepresentation(UIImage(data: data)!, 0.025)
                    self?.uploadImageToFirebase(image: NSData!, username: username,imageview: imageview)
                }}}}
    
    //This method simply checks to see if photourl is already saved in Firebase, retrieves it from there saves it in sharedpref and then loads image
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
    //Meh simple method man loads image to imageview
    private func setDisplay(imageview:UIImageView, profileurl:String){
        print("ProfileUrl: \(profileurl)")
        commonutil.loadImageViewURLFirebase(url: profileurl, imageview: imageview)
    }
    
    //Public method to call for loading userPhoto
    public func getMyPhoto(username:String, imageview:UIImageView){
        if let profilurl = commonutil.getUserData(key: "photourl"){
            //Set Display
            setDisplay(imageview: imageview, profileurl: profilurl)
        }else{
            checkIfPhotoIntialized(username: username, imageview: imageview)
        }
        
    }
    
    
}


