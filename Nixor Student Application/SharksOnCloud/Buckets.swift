

import UIKit
import FirebaseFirestore
import FirebaseDatabase
class Buckets: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
    

    @IBOutlet weak var myNixorPoints: UILabel!
    @IBOutlet weak var classNameMyBucket: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var class_type:String?
    var subjectName:String?
    var bucketArray = [BucketObject]()
    var userBucketsArray = [String]()
    var userAvatars = [String:String]()
    
    var searchActive = false
    var filteredbucketArray = [BucketObject]()
    
    @IBAction func openMyBucket(_ sender: Any) {
      //MyBucketViewController
        
        let MyBucketViewController = storyboard?.instantiateViewController(withIdentifier: "MyBucketViewController") as! MyBucketViewController
        if class_type == "AS"{
            MyBucketViewController.class_type = "AS"
        }else{
            MyBucketViewController.class_type = "A2"
        }
        
        MyBucketViewController.selectedSubject = subjectName
        
        self.navigationController?.pushViewController(MyBucketViewController, animated: true)
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return filteredbucketArray.count
        }else{
        
            return bucketArray.count}
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let studentBucker = storyboard?.instantiateViewController(withIdentifier: "studentBucker") as! studentBucker
        if class_type == "AS"{
            studentBucker.class_type = "AS"
        }else{
            studentBucker.class_type = "A2"
        }
        
        studentBucker.selectedSubject = subjectName
        
        if searchActive{
            studentBucker.userBucket = filteredbucketArray[indexPath.item].username;
        }else{
            studentBucker.userBucket = bucketArray[indexPath.item].username;}
        
        self.navigationController?.pushViewController(studentBucker, animated: true)
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "bucketsTableViewCell") as! bucketsTableViewCell
        cell.view.setCardView()
        cell.student_photo.circleImage()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        var myBucketArray = [BucketObject]();
        
        if searchActive{
            myBucketArray = filteredbucketArray
        }else{
            myBucketArray = bucketArray
        }
        
        if myBucketArray[indexPath.row].student_name != nil{
            cell.student_name.text = myBucketArray[indexPath.row].student_name
        }
        if  myBucketArray[indexPath.row].className != nil{
            cell.class_type.text = myBucketArray[indexPath.row].className
        }
        
        if let photourl = userAvatars[myBucketArray[indexPath.row].username!] {
            let photoURL = URL(string: photourl)
            cell.student_photo.kf.setImage(with: photoURL)
        }else{
        self.getPhotoUrl(username: myBucketArray[indexPath.row].username!, cell: cell)
        }
        
        
        return cell
    }
    
    func getPhotoUrl(username:String, cell:bucketsTableViewCell){
        
        Firestore.firestore().collection("users").document(username).getDocument { (response, error) in
            if error == nil && response != nil{
                if response?.get("photourl") != nil{
                    let url = URL(string: response?.get("photourl") as! String)
                    self.userAvatars[username] = (response?.get("photourl") as! String)
                    cell.student_photo.kf.setImage(with: url )
                    cell.student_photo.circleImage()
                    
                    if let indexPath:Int = self.userBucketsArray.index(of: username){
                    if self.bucketArray[indexPath].student_name == nil{
                        
                        if let student_name = response?.get("student_name") as? String{
                        cell.student_name.text = student_name
                        self.bucketArray[indexPath].student_name = student_name
                        }
                    }
                    }}
                
            }
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
         tableview.tableFooterView = UIView()
        tableview.rowHeight = 90
        
        
    self.title = "\(class_type!) \(subjectName!)"
        getAllBuckets()
        

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(Buckets.back(sender:)))
      
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        
    }
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
    }
  
   
    func getAllBuckets(){
        print("Getting all buckets")
        bucketArray = [BucketObject]()
        userBucketsArray = [String]()
        var ref:CollectionReference?
        switch class_type{
        case "AS":ref = constants.sharksOnCloudSubjectsAs
        case "A2":ref = constants.sharksOnCloudSubjectsA2
        default:break;
        }
        
        ref!.document(subjectName!).collection("Users").addSnapshotListener({ (query, error) in
            var student_name:String?
           // print(query?.count)
           // print(self.class_type)
            for documents in (query?.documents)!{
                print(documents)
                let username:String = documents.documentID
                if let className = documents["className"] as? String{
                    if let student_nameLocal = documents["student_name"] as? String{
                        student_name = student_nameLocal
                    }
                    
                    let bucketObject = BucketObject(username: username, student_name: student_name, className: className)
                    if !self.userBucketsArray.contains(username){
                    self.bucketArray.append(bucketObject)
                        self.userBucketsArray.append(username)
                        
                    }
                }
                
            }
            self.tableview.reloadData()
            
            
            
            
            
        })
        
        
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
     
   
        filteredbucketArray = filterObjects(text: searchText, paperObjectArray: bucketArray)
   
   
        searchActive = true
        
        if searchText == ""{
            searchActive = false
        }
        //
        tableview.reloadData()
        
    }
    
    
    //Search BucketObjects
    func stringContains(key:String, value:String) -> Bool{
        if key.contains(value) {
            return true
        }
        return false
    }
    func itContains(value:String,paperObject:BucketObject) -> Bool{
        
        if stringContains(key: paperObject.className!, value: value)
            ||  stringContains(key: paperObject.student_name!, value: value){
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    
    
    
    func filterObjects(text:String, paperObjectArray:[BucketObject]) -> [BucketObject]{
        var filteredPaperObjects = [BucketObject]()
     
        
        let constraint = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var firstsplit = constraint.split(separator: " ")
        // print(firstsplit.count)
        
        for indexPath in paperObjectArray.indices {
            var count = 0
            var found = 0
            
            for index in firstsplit.indices{
                let value = firstsplit[index].trimmingCharacters(in: .whitespacesAndNewlines).capitalized
              
                    count += 1
                    // print("Count: \(count)")
               
                let contains = itContains(value: value, paperObject: paperObjectArray[indexPath])
                //print("value: \(value) contains: \(contains)")
                if contains {
                    found += 1
                    // print("found: \(found)")
                    //print("Got here: \(value)")
                }
                
            }
            if found == count {
                filteredPaperObjects.append(paperObjectArray[indexPath])
               
            }
            
            
        }
       
        return filteredPaperObjects
    }
    

    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}
