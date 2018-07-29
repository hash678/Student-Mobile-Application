//
//  SharksOnCloud.swift
//  
//
//  Created by Hassan Abbasi on 08/07/2018.
//

import UIKit
import FirebaseFirestore
class SOCSubjects: UIViewController,UITableViewDelegate,UITableViewDataSource, addToFav,UISearchBarDelegate{
    
    var searchActive = false
    var commonUtil = common_util()
    var username:String?
    var selectedClassType = classTypeAsOrA2.AS
    var selectedSubjectList = [String]()
    var filteredSubjectList = [String]()
    
    var favSubjects = [String]()
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var header: headerMain!
    
    func setMyFavSubjects(){
        if favSubjects.count > 0
        let defaults = UserDefaults.standard
        defaults.set(favSubjects, forKey: "SOCFavSubjects")
tableview.reloadDate()
        
    }
    }

func getMyFavSubjects(){
    if let myarray = defaults.stringArray(forKey: "SOCFavSubjects") ?? [String](){
        favSubjects = myarray
    }
}

func addToFavSubjects(subjectName:String){
    favSubjects.append(subjectName)
setMyFavSubjects()
    
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = commonUtil.getUserData(key: "username")
         getSubjects(selectedClassType)
        getMyFavSubjects();
          tableview.tableFooterView = UIView()
            tableview.rowHeight = 60
        self.hideKeyboardWhenTappedAround()
   
    }
    @IBAction func showSubjectsSelection(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: selectedClassType = classTypeAsOrA2.AS
        case 1: selectedClassType = classTypeAsOrA2.A2
        default:break
        }
        getSubjects(selectedClassType)
        
    }
    func loadMySubjects(){
        constants.userDB.document(username!).getDocument { (document, error) in
            
            if error == nil{
                
                if document != nil{
                    if let value = document?.get("student_subjects") as? [String]{
                    self.selectedSubjectList = value

                        self.tableview.reloadData()}
                }
                
            }
            
        }
        
    }
  
    func getSubjects(_ classSelected:classTypeAsOrA2){
        selectedSubjectList = [String]()
        var ref:CollectionReference?
        switch classSelected {
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
        
        
       
        let BucketsController = storyboard?.instantiateViewController(withIdentifier: "Buckets") as! Buckets
        if selectedClassType == classTypeAsOrA2.AS{
              BucketsController.class_type = "AS"
        }else{
            BucketsController.class_type = "A2"
        }
        
        BucketsController.subjectName = selectedSubjectList[indexPath.row]
      
        self.navigationController?.pushViewController(BucketsController, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredSubjectList.count
        }
        return selectedSubjectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharksOnCloudSubjectCellTableViewCell") as! SubjectCellTableViewCell
        cell.delegate = self
        
        if searchActive{
            cell.subject_name.text = filteredSubjectList[indexPath.item]
            
        }else{
               cell.subject_name.text = selectedSubjectList[indexPath.item]
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
            filteredSubjectList = selectedSubjectList.filter({( text : String) -> Bool in
                return text.lowercased().contains(searchText.lowercased())
            })

            searchActive = true

            if searchText == ""{
                searchActive = false
            }
            tableview.reloadData()

        
    }
    
    
}


enum classTypeAsOrA2{
    case AS
    case A2

}

