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
    
    var favSubjectsAS = [String]()
    var favSubjectsA2 = [String]()

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var header: headerMain!

    func setMyFavSubjects(){
        var favSubjects = [String]()
        let defaults = UserDefaults.standard
        if selectedClassType == .AS{
            favSubjects = favSubjectsAS
            
            defaults.set(favSubjects, forKey: "SOCFavSubjectsAS")
        }else{
            favSubjects = favSubjectsA2
            defaults.set(favSubjects, forKey: "SOCFavSubjectsA2")
        }
        
        if favSubjects.count > 0{
       
        }

    }


func getMyFavSubjects(){
    let defaults = UserDefaults.standard

    if selectedClassType == .AS{
        favSubjectsAS  = defaults.stringArray(forKey: "SOCFavSubjectsAS") ?? [String]()
    }else{
        favSubjectsA2  = defaults.stringArray(forKey: "SOCFavSubjectsA2") ?? [String]()
    }
  
  
    
}

func addToFavSubjects(subjectName:String){
    
   
    if selectedClassType == .AS{
        favSubjectsAS.append(subjectName)
    }else{
         favSubjectsA2.append(subjectName)
    }
    
    
    setMyFavSubjects()

}
    
    func removeFromFavSubjects(subjectName:String){
        
        
        
       
        if selectedClassType == .AS{
             if favSubjectsAS.contains(subjectName){
                favSubjectsAS.remove(at: favSubjectsAS.index(of: subjectName)!)}
        }else{
             if favSubjectsA2.contains(subjectName){
            
                favSubjectsA2.remove(at: favSubjectsA2.index(of: subjectName)!)}
        }
            setMyFavSubjects()
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        username = commonUtil.getUserData(key: "username")
         getSubjects(selectedClassType)
       
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
        getMyFavSubjects()
        selectedSubjectList = [String]()
        tableview.reloadData()
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
                
                  self.selectedSubjectList = self.sortSelectedSubjectList(list:self.selectedSubjectList)
                self.tableview.reloadData()
            }else{
                //TODO: Exception handling - add it bitch
            }
            
            
            
        })
        
        
    }
    
    func sortSelectedSubjectList(list:[String]) -> [String]{
        var returnList = [String]()
        for value in list{
            
            if selectedClassType == .AS{
                if favSubjectsAS.contains(value){
                    returnList.append(value)
                }
                
            }else{
                if favSubjectsA2.contains(value){
                    returnList.append(value)
                }
                
            }
            
        }
            
            
        for value in list{
            
            if selectedClassType == .AS{
                if !favSubjectsAS.contains(value){
                    returnList.append(value)
                }
                
            }else{
                if !favSubjectsA2.contains(value){
                    returnList.append(value)
                }
                
            }
            
        }
        
        return returnList
        
    }
    
    
    func addToFav(sender: IndexPath) {
        let cell = tableView(tableview, cellForRowAt: sender) as! SubjectCellTableViewCell
        if let subjecName = cell.subject_name.text{
            
            if selectedClassType == .AS{
                
                if !favSubjectsAS.contains(subjecName){
                    addToFavSubjects(subjectName: subjecName)
                    
                    
                    
                    
                }else{
                    removeFromFavSubjects(subjectName: subjecName)
                    
                    cell.heartButton.setImage(#imageLiteral(resourceName: "heartIconUnselected"), for: .normal)
                    
                    
                }
                
            }else{
               
                    
                    if !favSubjectsA2.contains(subjecName){
                        addToFavSubjects(subjectName: subjecName)
                        
                        
                        
                        
                    }else{
                        removeFromFavSubjects(subjectName: subjecName)
                        
                        cell.heartButton.setImage(#imageLiteral(resourceName: "heartIconUnselected"), for: .normal)
                        
                        
                    }
                
            }
            
            
            
         
              tableview.reloadRows(at: [sender], with: .automatic)
            
        }
    }
    
    
    
   //TableView methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
       
        let BucketsController = storyboard?.instantiateViewController(withIdentifier: "Buckets") as! Buckets
        if selectedClassType == classTypeAsOrA2.AS{
              BucketsController.class_type = "AS"
        }else{
            BucketsController.class_type = "A2"
        }
        let subjectName:String?
        if searchActive{
             subjectName = filteredSubjectList[indexPath.row]
        }else{
            subjectName  = selectedSubjectList[indexPath.row]}
         BucketsController.subjectName = subjectName
      
        self.navigationController?.pushViewController(BucketsController, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredSubjectList.count
        }else{
            return selectedSubjectList.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharksOnCloudSubjectCellTableViewCell") as! SubjectCellTableViewCell
       cell.indexpath = indexPath
        cell.delegate = self
        
       
        var subjectName:String?
        if searchActive{
          
          subjectName = filteredSubjectList[indexPath.row]
            
        }else{
            
               subjectName = selectedSubjectList[indexPath.row]
        }
        
        cell.subject_name.text = subjectName
        if subjectName != nil{
            
            var favSubjects = [String]()
            if selectedClassType == .AS{
                favSubjects = favSubjectsAS
                
            }else{
                favSubjects = favSubjectsA2
            }
            
            if favSubjects.contains(subjectName!){
               
                cell.heartButton.setImage(#imageLiteral(resourceName: "heartIcon"), for: .normal)
            }else{
                
                 cell.heartButton.setImage(#imageLiteral(resourceName: "heartIconUnselected"), for: .normal)
            }
        }
        

        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == ""{
            searchActive = false

        }else{
            searchActive = true
        }
        
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

