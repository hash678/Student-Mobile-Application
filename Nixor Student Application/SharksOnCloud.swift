//
//  SharksOnCloud.swift
//  
//
//  Created by Hassan Abbasi on 08/07/2018.
//

import UIKit
import FirebaseFirestore
class SharksOnCloud: UIViewController,UITableViewDelegate,UITableViewDataSource, addToFav{
    
    
    var commonUtil = common_util()
    var username:String?
    var selectedClassType = classType.mySubjects
    var selectedSubjectList = [String]()
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var header: headerMain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = commonUtil.getUserData(key: "username")
         getSubjects(selectedClassType)
          tableview.tableFooterView = UIView()
            tableview.rowHeight = 65
   
    }
    @IBAction func showSubjectsSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: selectedClassType = classType.mySubjects
        case 1: selectedClassType = classType.AS
        case 2: selectedClassType = classType.A2
        default:break
        }
        getSubjects(selectedClassType)
        
    }
    func loadMySubjects(){
        constants.userDB.document(username!).getDocument { (document, error) in
            
            if error == nil{
                
                if document != nil{
                    
                    self.selectedSubjectList = document?.get("student_subjects") as! [String]

                    self.tableview.reloadData()
                }
                
            }
            
        }
        
    }
  
    func getSubjects(_ classSelected:classType){
        selectedSubjectList = [String]()
        var ref:CollectionReference?
        switch classSelected {
        case .mySubjects: self.loadMySubjects(); return
        case .A2: ref = constants.sharksOnCloudSubjectsA2
        case .AS: ref = constants.sharksOnCloudSubjectsA2
        }
        
        ref!.getDocuments(completion: { (query, error) in
            
            if error == nil {
                if query != nil {
                for document in query!.documents{
                    self.selectedSubjectList.append(document.documentID)
                    }
                    
                }
                self.tableview.reloadData()
            }else{
                //TODO: Exception handling - add it bitch
            }
            
            
            
        })
        
        
    }
    
    
    func addToFav(added: Bool) {
        //TODO: Add to fav code
    }
    
    
    
   //TableView methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
       print("Clicked")
        let BucketsController = storyboard?.instantiateViewController(withIdentifier: "Buckets") as! Buckets
        self.navigationController?.pushViewController(BucketsController, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSubjectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharksOnCloudSubjectCellTableViewCell") as! sharksOnCloudSubjectCellTableViewCell
        cell.delegate = self
        cell.subject_name.text = selectedSubjectList[indexPath.item]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    
    
}

enum classType{
    case AS
    case A2
    case mySubjects
}

