//
//  PaperDownload.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 07/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
import FirebaseStorage

class paperDownload{

    public func downloadPDF(paperName:String, subject:String){
       let storageRef = Storage.storage().reference()
        let islandRef = storageRef.child("PastPapers").child("Subjects").child(subject).child(paperName)
        
        // Create local filesystem URL
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(paperName)
        // Download to the local filesystem
        let downloadTask = islandRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error is: \(error)")
            } else {
                print("Success Man: \(paperName)")
            }
        }
    }
    
}
