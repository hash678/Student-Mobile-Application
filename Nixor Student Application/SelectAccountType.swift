//
//  SelectAccountType.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 22/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
class SelectAccountType: UIViewController {

    var fcmToken:String?
    
    
    @IBAction func parent_mode(_ sender: Any) {
    
    
    }
    
    @IBAction func student_mode(_ sender: Any) {
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func uploadFirebaseToken(accontType:accountType){
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
              self.fcmToken = result.token
            }
        }
        
        
        
    }
    
    
    
    
    
//    private void uploadFirebaseTokenParent() {
//    tokenForMessageing = FirebaseInstanceId.getInstance().getToken();
//    ParentFirebaseTokens = new ArrayList<>();
//    dr = FirebaseFirestore.getInstance().collection("/users/talha-siddiqui/FirebaseTokens").document("ParentTokens");
//    final Map<String, Object> uploadData = new HashMap<>();
//
//    dr.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
//    @Override
//    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
//
//    DocumentSnapshot documentSnapshot = task.getResult();
//    if (documentSnapshot.get("parentFirebaseTokens")==null) {
//    ParentFirebaseTokens.add(tokenForMessageing);
//    uploadData.put("parentFirebaseTokens", ParentFirebaseTokens);
//    dr.set(uploadData,SetOptions.merge());
//    Log.i(TAG, "uploaded data inside if");
//    } else {
//    dr.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
//    @Override
//    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
//    ParentFirebaseTokens = (ArrayList<String>) task.getResult().get("parentFirebaseTokens");
//    ParentFirebaseTokens.add(tokenForMessageing);
//    uploadData.put("parentFirebaseTokens", ParentFirebaseTokens);
//    UploadToken(uploadData);
//    Log.i(TAG, "uploaded data inside else");
//    }
//    });
//
//    }
//    }
//
//    });
//
//    }
//
//    private void uploadFirebaseTokenStudent() {
//
//    tokenForMessageing = FirebaseInstanceId.getInstance().getToken();
//    StudentFirebaseTokens = new ArrayList<>();
//    dr = FirebaseFirestore.getInstance().collection("/users").document("talha-siddiqui");
//    final Map<String, Object> uploadData = new HashMap<>();
//
//    dr.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
//    @Override
//    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
//
//    DocumentSnapshot documentSnapshot = task.getResult();
//    if (documentSnapshot.get("studentFirebaseTokens")==null) {
//    StudentFirebaseTokens.add(tokenForMessageing);
//    uploadData.put("studentFirebaseTokens", StudentFirebaseTokens);
//    dr.set(uploadData, SetOptions.merge());
//    Log.i(TAG, "uploaded data inside if");
//    } else {
//    dr.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
//    @Override
//    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
//    StudentFirebaseTokens = (ArrayList<String>) task.getResult().get("studentFirebaseTokens");
//    StudentFirebaseTokens.add(tokenForMessageing);
//    uploadData.put("studentFirebaseTokens", StudentFirebaseTokens);
//    UploadToken(uploadData);
//    Log.i(TAG, "uploaded data inside else");
//    }
//    });
//
//    }
//    }
//
//    });
//
//    }
    
    
}


enum accountType{
    case parent
    case student
}
