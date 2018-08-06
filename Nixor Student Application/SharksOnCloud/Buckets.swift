import UIKit
import FirebaseFirestore
import FirebaseDatabase
class Buckets: GeneralLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    
    @IBOutlet weak var myNixorPoints: UILabel!
    @IBOutlet weak var classNameMyBucket: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var class_type:String?
    var subjectName:String?
    var bucketArray = [BucketObject]()
    var userBucketsArray = [String]()
    var userAvatars = [String:String]()
    let commonUtil = common_util()
    var searchActive = false
    var filteredbucketArray = [BucketObject]()
    var username:String?
    
    @IBAction func openMyBucket(_ sender: Any) {
        //MyBucketViewController
        
        let MyBucketViewController = storyboard?.instantiateViewController(withIdentifier: "BucketViewController") as! BucketViewController
        if class_type == "AS"{
            MyBucketViewController.class_type = "AS"
        }else{
            MyBucketViewController.class_type = "A2"
        }
        
        MyBucketViewController.selectedSubject = subjectName
        MyBucketViewController.bucketUser = username
        
        self.navigationController?.pushViewController(MyBucketViewController, animated: true)
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return filteredbucketArray.count
        }else{
            
            return bucketArray.count}
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let MyBucketViewController = storyboard?.instantiateViewController(withIdentifier: "BucketViewController") as! BucketViewController
        if class_type == "AS"{
            MyBucketViewController.class_type = "AS"
        }else{
            MyBucketViewController.class_type = "A2"
        }
        
        MyBucketViewController.selectedSubject = subjectName
        
        if searchActive{
            MyBucketViewController.bucketUser = filteredbucketArray[indexPath.item].username;
        }else{
            MyBucketViewController.bucketUser = bucketArray[indexPath.item].username;}
        
        self.navigationController?.pushViewController(MyBucketViewController, animated: true)
        
        
        
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
           
            cell.student_photo.setImage(url: photourl)
        }else{
            self.getPhotoUrl(username: myBucketArray[indexPath.row].username!, cell: cell)
        }
        
        
        return cell
    }
    
    func getPhotoUrl(username:String, cell:bucketsTableViewCell){
        
        Firestore.firestore().collection("users").document(username).getDocument { (response, error) in
            if error == nil && response != nil{
                if response?.get("photourl") != nil{
                   
                    self.userAvatars[username] = (response?.get("photourl") as! String)
                   
                    cell.student_photo.setImage(url: response?.get("photourl") as! String )
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
        username = commonUtil.getUserData(key: "username")
        self.hideKeyboardWhenTappedAround()
        tableview.tableFooterView = UIView()
        tableview.rowHeight = 90
        self.title = "\(class_type!) \(subjectName!)"
        getAllBuckets()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(Buckets.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton}
    
    @objc func back(sender: UIBarButtonItem){navigationController?.popViewController(animated: true)}
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
            for documents in (query?.documents)!{
                print(documents)
                let username:String = documents.documentID
                
                if username != self.username{
                if let className = documents["className"] as? String{
                    if let student_nameLocal = documents["student_name"] as? String{
                        student_name = student_nameLocal}
                    let bucketObject = BucketObject(username: username, student_name: student_name, className: className)
                    if !self.userBucketsArray.contains(username){
                        self.bucketArray.append(bucketObject)
                        self.userBucketsArray.append(username)}}
                        self.tableview.reloadData()
                }}
            })}
    
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == ""{
            searchActive = false
        }else{searchActive = true}}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false}
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true}
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredbucketArray = filterObjects(text: searchText, paperObjectArray: bucketArray)
        searchActive = true
        if searchText == ""{searchActive = false}
        tableview.reloadData()}
    
    
    

    func filterObjects(text:String, paperObjectArray:[BucketObject]) -> [BucketObject]{
        var filteredPaperObjects = [BucketObject]()
        for indexPath in paperObjectArray.indices {
           let contains = commonUtil.NewfilterObjects(text: text, exclude: [String]()) { (value) -> Bool in
                self.commonUtil.itContains(value: value, object: paperObjectArray[indexPath])
                }
            if contains{
                filteredPaperObjects.append(paperObjectArray[indexPath])
            }
            
            
        }
        
        
        return filteredPaperObjects
    }
  
    
}




