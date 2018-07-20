//
//  PastPapers.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 06/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
class PastPapers: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    var subjects = [String]()
    let userClass = UserPhoto()
    var username:String?
    let commonutil = common_util()
    var paperObjectList = [paperObject]()
    var paperUrlList = [String]()
    var indicator: UIActivityIndicatorView?
    var subjectSelected:String?
    var multiviewOn = false
    var selectedRow:IndexPath?
    var selectedPaperURL:String?
    var secondSelectedPaperUrl:String?
    var secondSelectedRow:IndexPath?
    
    var singlePaperSelectedRow:IndexPath?
    
    let rowPaperHeight:CGFloat = 120
    let rowSubjectHeight:CGFloat = 75
    
    //Search
    
    var filteredSubjects = [String]()
    var filteredPaperObjects = [paperObject]()
    var filteredPaperUrls = [String]()
    var searchActive : Bool = false
    
    //StoryBoard Variables
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var multiviewSwitch: UISegmentedControl!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var multiViewView: UIView!
    
    @IBOutlet weak var headermain: headerMain!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    
    //Function for count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if subjectSelected == nil {
            
            if(searchActive) {
                return filteredSubjects.count
            }else{
                return subjects.count
            }
        }else{
            if searchActive{
                return filteredPaperUrls.count
            }else{
                return paperObjectList.count
            }
            
        }
        
    }
    
    
   
    //Tableview design
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indicator!.isAnimating{
            indicator!.stopAnimating()
        }
        
        if subjectSelected == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! subjectCellTableViewCell
            if subjects.count > indexPath.row{
                
                if searchActive {
                    if filteredSubjects.count > indexPath.row{
                        cell.subjectName.text! = filteredSubjects[indexPath.row]}
                }else{
                    cell.subjectName.text! = subjects[indexPath.row]
                }
                
            }
            let customColorView = UIView.init()
            customColorView.backgroundColor = #colorLiteral(red: 0.4078431373, green: 0.007843137255, blue: 0.007843137255, alpha: 1)
            cell.selectedBackgroundView = customColorView
            self.tableView.rowHeight = rowSubjectHeight
            
            return cell
            
        }else{
            
            var cell:UITableViewCell
            
            
            
            if searchActive{
                cell = self.getPaperCell(indexPath: indexPath.row, paper: filteredPaperObjects[indexPath.row])
            }else{
                cell = self.getPaperCell(indexPath: indexPath.row, paper: paperObjectList[indexPath.row])
            }
            
            if multiviewOn && selectedPaperURL != nil {
                if searchActive{
                    if filteredPaperUrls.contains(selectedPaperURL!){
                        if indexPath.item == filteredPaperUrls.index(of: selectedPaperURL!){
                            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.init(rawValue: indexPath.item)!)
                        }
                    }else{
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    
                }else{
                
                if paperUrlList.contains(selectedPaperURL!){
                if indexPath.item == paperUrlList.index(of: selectedPaperURL!){
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.init(rawValue: indexPath.item)!)
                }
                }else{
                     tableView.deselectRow(at: indexPath, animated: true)
                    }}
                
                
            }
            
            let customColorView = UIView.init()
            customColorView.backgroundColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2938249144)
            cell.selectedBackgroundView = customColorView
            
            self.tableView.rowHeight = rowPaperHeight
            return cell
            
            
        }
        
        
        
        
    }
    
    //On Click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected cell \(indexPath.row)")
        //Subjects
        if subjectSelected == nil {
            if searchActive{
                searchActive = false
                
                getPapers(subjectName: filteredSubjects[indexPath.row],onlythesepapers:nil)}
            else{
                getPapers(subjectName: subjects[indexPath.row],onlythesepapers:nil)}
        }
            
            //Paper
        else{
            //MultiView
            if multiviewOn{
                
                if selectedRow == nil {
                    selectedRow = indexPath
                    if searchActive {
                        selectedPaperURL = filteredPaperUrls[indexPath.row]
                    }else{
                        selectedPaperURL = paperUrlList[indexPath.row]
                        
                    }
                }else {
                    secondSelectedRow = indexPath
                    if searchActive {
                        secondSelectedPaperUrl = filteredPaperUrls[indexPath.row]
                    }else{
                        secondSelectedPaperUrl = paperUrlList[indexPath.row]
                        
                    }
                    indicator?.startAnimating()
                    
                    if searchActive{
                        self.downloadPDF(paperName: selectedPaperURL!, subject: subjectSelected!, isItMultiview: true)
                    }else{
                        self.downloadPDF(paperName: selectedPaperURL!, subject: subjectSelected!, isItMultiview: true)
                    }
                    
                    
                }
                
                
                
                
            }else{
                //let downloadClass = paperdownload()
                indicator?.startAnimating()
                singlePaperSelectedRow = indexPath
                if searchActive {
                    self.downloadPDF(paperName: filteredPaperUrls[indexPath.row], subject: subjectSelected!, isItMultiview: false)
                }else{
                    self.downloadPDF(paperName: paperUrlList[indexPath.row], subject: subjectSelected!, isItMultiview: false)
                }
                
            }
            
        }
    }
    //Gets subjects
    func getSubjects(){
        searchBar.text = ""
        searchActive = false
         self.title = "Past Papers"
        self.view.endEditing(true)
        multiViewView.isHidden = true
        subjects = [String]()
        self.tableView.rowHeight = rowSubjectHeight
        subjectSelected = nil
        selector.removeAllSegments()
        selector.insertSegment(withTitle: "All", at: 0, animated: true)
        selector.insertSegment(withTitle: "Sciences", at: 1, animated: true)
        selector.insertSegment(withTitle: "Commerce", at: 2, animated: true)
        selector.insertSegment(withTitle: "Other", at: 3, animated: true)
        selector.selectedSegmentIndex = 0
        indicator!.startAnimating()
        constants.pastpaperSubjectDB.getDocument { (document, error) in
            if document != nil{
                let data = document?.data()
                for indexPath in (data?.indices)!{
                    self.subjects.append(data![indexPath].value as! String)
                    
                    //print ("Value: \(data![indexPath].value)")
                    //print("Something else: \(data?.count)")
                }
                self.subjects.sort()
                self.tableView.reloadData()
            }
        }
    }
    
    
    //Gets papers for the subject
    func getPapers(subjectName:String, onlythesepapers:String?){
        self.view.endEditing(true)
        searchBar.text = ""
        searchActive = false
          self.title = subjectName
        
        multiViewView.isHidden = false
        paperObjectList = [paperObject]()
        paperUrlList = [String]()
        self.tableView.rowHeight = rowPaperHeight
        subjects = [String]()
        self.tableView.reloadData()
        
        if subjectSelected == nil{
            selector.removeAllSegments()
            selector.insertSegment(withTitle: "All", at: 0, animated: true)
            selector.insertSegment(withTitle: "QP", at: 1, animated: true)
            selector.insertSegment(withTitle: "MS", at: 2, animated: true)
            selector.insertSegment(withTitle: "ER", at: 3, animated: true)
            selector.insertSegment(withTitle: "GT", at: 4, animated: true)
            selector.selectedSegmentIndex = 0}
        subjectSelected = subjectName
        indicator!.startAnimating()
        var query:Query
        if onlythesepapers == nil {
            query = constants.pastpaperSubjects.collection(subjectName).order(by: "year")
        }else{
            query = constants.pastpaperSubjects.collection(subjectName).whereField("type", isEqualTo: onlythesepapers!)
        }
        query.getDocuments { (Query, error) in
            if Query != nil{
                
                for documents in Query!.documents{
                    let docs:Dictionary = documents.data()
                    if docs["name"] != nil{
                        //  map.get("month"), map.get("year"), map.get("variant"), map.get("type"))
                        let paper = self.addDataToObject(monthO: docs["month"] as? String, yearO: docs["year"] as? String, variantO: docs["variant"] as? String, typeO: docs["type"] as? String)
                        if !self.isPaperObjectInvalid(paperObject: paper){
                        //    print(paper)
                            self.paperUrlList.append(docs["name"] as! String)
                            self.paperObjectList.append(paper)
                            
                        }
                        
                    }
                    
                }
                
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    //Checks if paper object is invalid
    func isPaperObjectInvalid(paperObject: paperObject) -> Bool {
        if (paperObject.month != "error") {
            return false
        }
        if (paperObject.year != "error") {
            return false
        }
        if (paperObject.type != "error") {
            return false
        }
        if (paperObject.variant != "error") {
            return false
        }
        return true
    }
    
    //Basic intialization
    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboardWhenTappedAround()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PastPapers.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.tableView.tableFooterView = UIView()
        intLoading()
        setMyData()
        getSubjects()
        searchBar.delegate = self
        
    }
    
    //Simple meethod to convert data from firebase into a paper object.
    func addDataToObject(monthO: String? ,yearO: String? ,variantO:String?,typeO:String?) -> paperObject {
        var paper = paperObject()
        if let month = monthO{
            paper.month = month
        }else{
            paper.month = "error"
        }
        if let year = yearO{
            paper.year = year
        }else{
            paper.year = "error"
        }
        if let variant = variantO{
            paper.variant = variant
        }else{
            paper.variant = "error"
        }
        
        if let type = typeO{
            paper.type = type
        }else{
            paper.type = "error"
        }
        return paper
        
    }
    
    //Function to setHeaderData
    func setMyData(){
        //    student_photo.circleImage()
        if let username_local = commonutil.getUserData(key: "username"){
            //  userClass.getMyPhoto(username: username_local, imageview: student_photo!)
            username = username_local
        }
        
    }
    //Creates your paper cell
    func getPaperCell(indexPath: Int, paper: paperObject) -> paperCellTableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paperCell") as! paperCellTableViewCell
        
        cell.view.giveMeShadowsBitch()
        if paper.month != "error"{
            cell.monthLabel.text = paper.month
           
            switch (paper.month!) {
            case "Winter":
                cell.monthImage.image = #imageLiteral(resourceName: "snow_flake")
            case "Summer":
                cell.monthImage.image = #imageLiteral(resourceName: "summer_icon")
            case "March":
             cell.monthImage.image = #imageLiteral(resourceName: "spring_icon")
            default:break
            }
           }else {
            cell.monthLabel.alpha = 0
        }
        
        if paper.year != "error"{
            cell.yearLabel.text = paper.year
        }else {
            cell.yearLabel.alpha = 0
        }
        
        if paper.type != "error"{
            cell.typeLabel.text = paper.type
        }else {
            cell.typeLabel.alpha = 0
        }
        
        if paper.variant != "error"{
            cell.variantLabel.text = paper.variant
        }else {
            cell.variantLabel.alpha = 0
        }
        
        return cell
    }
    
  
  
    //Filter for papers
    @IBAction func onSelectionChange(_ sender: UISegmentedControl) {
        if subjectSelected !=  nil{
            switch (sender.selectedSegmentIndex){
            case 0: getPapers(subjectName: subjectSelected!, onlythesepapers: nil)
            case 1:getPapers(subjectName: subjectSelected!, onlythesepapers: "Question Paper")
            case 2:getPapers(subjectName: subjectSelected!, onlythesepapers: "Marking Scheme")
            case 4:getPapers(subjectName: subjectSelected!, onlythesepapers: "Grade Threshold")
            case 3:getPapers(subjectName: subjectSelected!, onlythesepapers: "Examiner Report")
            default:break
            }
            
        }
        
    }
    //Just some basic loading and shashkay scene
    func intLoading(){
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator!.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        indicator!.center = view.center
        indicator!.color = #colorLiteral(red: 0.5647058824, green: 0, blue: 0, alpha: 1)
        self.view.addSubview(indicator!)
        self.view.bringSubview(toFront: indicator!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    //Downloads paper and if multiview is selected calls download second paper method else opens pdf viewer
    func downloadPDF(paperName:String, subject:String, isItMultiview:Bool){
        
        let storageRef = Storage.storage().reference()
        let islandRef = storageRef.child("PastPapers").child("Subjects").child(subject).child(paperName)
        
        // Create local filesystem URL
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(paperName)
        if  !FileManager().fileExists(atPath: localURL.path){
            // Download to the local filesystem
            let _ = islandRef.write(toFile: localURL) { url, error in
                
                if let error = error {
                    print("Error is: \(error)")
                    if(self.indicator?.isAnimating)!{
                        self.indicator?.stopAnimating()
                    }
                } else {
                    print("Success Man: \(paperName)")
                    if !isItMultiview{
                        self.openPDFViewer(url: localURL,secondPaper: nil)}else{
                        self.downloadSecondPDF(paperName: self.secondSelectedPaperUrl!, subject: subject, previousPaper: localURL)
                    }
                }
            }
        }else{
            print("Success Man: \(paperName)")
            
            if !isItMultiview{
                self.openPDFViewer(url: localURL,secondPaper: nil)}else{
                self.downloadSecondPDF(paperName: secondSelectedPaperUrl!, subject: subject, previousPaper: localURL)
            }
            
        }
        
        
    }
    
    //Download's the second paper and passes the URL of the first paper to the open pdf viewer method
    func downloadSecondPDF(paperName:String, subject:String, previousPaper:URL){
        
        let storageRef = Storage.storage().reference()
        let islandRef = storageRef.child("PastPapers").child("Subjects").child(subject).child(paperName)
        
        // Create local filesystem URL
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(paperName)
        if  !FileManager().fileExists(atPath: localURL.path){
            // Download to the local filesystem
            let _ = islandRef.write(toFile: localURL) { url, error in
                if let error = error {
                    print("Error is: \(error)")
                    if(self.indicator?.isAnimating)!{
                        self.indicator?.stopAnimating()
                    }
                } else {
                    print("Success Man: \(paperName)")
                    
                    self.openPDFViewer(url: localURL,secondPaper: previousPaper)}
                //Download Second paper
            }
            
        }else{
            print("Success Man: \(paperName)")
            self.openPDFViewer(url: localURL,secondPaper: previousPaper)}
        
        
        
        
    }
    //Open's PDF. Checks if MultiView is required or Single paper view.
    func openPDFViewer(url: URL, secondPaper:URL?){
        //        let document = PDFDocument(url: url)!
        //      let readerController = PDFViewController.createNew(with: document)
        //    navigationController?.pushViewController(readerController, animated: true)
        if(indicator?.isAnimating)!{
            indicator?.stopAnimating()
        }
        if secondPaper == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let singleView = storyboard.instantiateViewController(withIdentifier: "pdfIntent")as! PdfLoader
            singleView.url = url
            self.tableView.deselectRow(at: singlePaperSelectedRow!, animated: true)
            self.present(singleView,animated: true, completion: nil)
            
        }else{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let multiView = storyboard.instantiateViewController(withIdentifier: "multiview")as! pdfMultiView
            multiView.secondPaper = url
            multiView.firstPaper = secondPaper
            
            self.tableView.deselectRow(at: secondSelectedRow!, animated: true)
            
            self.tableView.deselectRow(at: selectedRow!, animated: true)
            selectedRow = nil
            selectedPaperURL = nil
            secondSelectedPaperUrl = nil
            self.present(multiView,animated: true, completion: nil)
        }
        
        
    }
    @objc func back(sender: UIBarButtonItem) {
        if subjectSelected == nil {
            searchActive = false
            searchBar.text = ""
            
              navigationController?.popViewController(animated: true)
            
        } else{
            searchActive = false
            searchBar.text = ""
            getSubjects()
            
        }
     
    }
   
    
    
    //Switch to switch on and off MultiView.
    @IBAction func onMultiVIewSwitch(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0: multiviewOn = false
        self.showToast(message: "MultiView is off")
        if let index = selectedRow{ self.tableView.deselectRow(at: index, animated: true)};
            selectedPaperURL = nil;selectedRow = nil
        case 1: multiviewOn = true
        self.showToast(message: "MultiView is on")
            
        default: break
        }
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
        
        
        if subjectSelected == nil {
            filteredSubjects = subjects.filter({( candy : String) -> Bool in
                return candy.lowercased().contains(searchText.lowercased())
            })
            
             searchActive = true

            if searchText == ""{
                searchActive = false
            }
            
            tableView.reloadData()
        }else{

            let obtanedTulips = filterSubjects(text: searchText, paperObjectArray: paperObjectList, paperListUrl: paperUrlList)
            filteredPaperObjects = obtanedTulips.paperS
            filteredPaperUrls = obtanedTulips.paperUrls
            
//            if(filteredPaperObjects.count == 0){
//                searchActive = false
//            } else {
            
            
                searchActive = true
            
            if searchText == ""{
                searchActive = false
            }
//
            tableView.reloadData()
        }
        
        
        
    }
    
    
    
    
    //Search Subjects
    func stringContains(key:String, value:String) -> Bool{
        if key.contains(value) {
            return true
        }
        return false
    }
    func itContains(value:String,paperObject:paperObject) -> Bool{
        
        if (stringContains(key: paperObject.variant!, value: value)
            ||  stringContains(key: paperObject.year!, value: value)
            ||  stringContains(key: paperObject.month!, value: value)
            ||  stringContains(key: paperObject.type!, value: value)
            ) {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    
    
    
    func filterSubjects(text:String, paperObjectArray:[paperObject],paperListUrl:[String]) -> (paperUrls:[String], paperS:[paperObject]){
        var filteredPaperObjects = [paperObject]()
        var filteredPaperUrls = [String]()
        var returnTulip = (filteredPaperUrls,filteredPaperObjects)
        let constraint = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var firstsplit = constraint.split(separator: " ")
       // print(firstsplit.count)
        
        for indexPath in paperObjectArray.indices {
            var count = 0
            var found = 0
            
            for index in firstsplit.indices{
                let value = firstsplit[index].trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                if(value != "PAPER" || value != "SCHEME"){
                    count += 1
                   // print("Count: \(count)")
                }else{
                    count += 1
                    found += 1
                }
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
                filteredPaperUrls.append(paperListUrl[indexPath])
            }
            
           
        }
         returnTulip = (filteredPaperUrls,filteredPaperObjects)
        return returnTulip
    }
    
    

    
}


