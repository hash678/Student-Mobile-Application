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
import NVActivityIndicatorView
class PastPapers: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,NVActivityIndicatorViewable{
    
    var subjects = [String]()
    let userClass = UserPhoto()
    var username:String?
    let commonutil = common_util()
    var paperObjectList = [paperObject]()
    var subjectSelected:String?
    var multiviewOn = false
    var selectedRow:IndexPath?
    var selectedPaperURL:String?
    var secondSelectedPaperUrl:String?
    var secondSelectedRow:IndexPath?
    var singlePaperSelectedRow:IndexPath?
    let rowPaperHeight:CGFloat = 120
    let rowSubjectHeight:CGFloat = 60
    
    //Search
    
    var filteredSubjects = [String]()
    var filteredPaperObjects = [paperObject]()
    var searchActive : Bool = false
    
    //StoryBoard Variables
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var multiviewSwitch: UISegmentedControl!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var multiViewView: UIView!
    @IBOutlet weak var headermain: headerMain!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let commonUtil = common_util()
    var showingloading = false
    
    
    //Function for count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if subjectSelected == nil {
            
            if(searchActive) {
                return filteredSubjects.count
            }else{
                return subjects.count}
        }else{
            if searchActive{
                return filteredPaperObjects.count
            }else{
                return paperObjectList.count
            }
            
        }
        
    }
    
    
   
    //Tableview design
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.stopLoading {
            
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
                      let found = filteredPaperObjects.filter{$0.url == selectedPaperURL}.count > 0
                    if found{
                        if indexPath.item == filteredPaperObjects.index(where: { $0.url == selectedPaperURL }){
                            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.init(rawValue: indexPath.item)!)
                        }
                    }else{
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    
                }else{
                 let found = paperObjectList.filter{$0.url == selectedPaperURL}.count > 0
                if found {
                if indexPath.item == paperObjectList.index(where: { $0.url == selectedPaperURL }){
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
                        selectedPaperURL = filteredPaperObjects[indexPath.row].url!
                    }else{
                        selectedPaperURL = paperObjectList[indexPath.row].url!
                        
                    }
                }else {
                    secondSelectedRow = indexPath
                    if searchActive {
                        secondSelectedPaperUrl = filteredPaperObjects[indexPath.row].url!
                    }else{
                        secondSelectedPaperUrl =  paperObjectList[indexPath.row].url!
                        
                    }
                 self.showLoading()
                    print("Called here1")
                    
                    if searchActive{
                        self.downloadPDF(paperName: selectedPaperURL!, subject: subjectSelected!, isItMultiview: true)
                    }else{
                        self.downloadPDF(paperName: selectedPaperURL!, subject: subjectSelected!, isItMultiview: true)
                    }
                    
                    
                }
                
                
                
                
            }else{
    
                    //self.showLoading()
           

                singlePaperSelectedRow = indexPath
                if searchActive {
                    self.downloadPDF(paperName: filteredPaperObjects[indexPath.row].url!, subject: subjectSelected!, isItMultiview: false)
                }else{
                    self.downloadPDF(paperName:  paperObjectList[indexPath.row].url!, subject: subjectSelected!, isItMultiview: false)
                }
                
            }
            
        }
    }
    
    
    func showLoading(){
        let size = CGSize(width: 40, height: 40)
           startAnimating(size, message: "Please wait", messageFont: nil, type: NVActivityIndicatorType.ballScale, color: #colorLiteral(red: 0.5649999976, green: 0, blue: 0, alpha: 1), padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor:#colorLiteral(red: 0.7897366751, green: 0.7897366751, blue: 0.7897366751, alpha: 0.75), textColor: nil, fadeInAnimation: nil)
    }
    func saveSubjects(){
    
        let defaults = UserDefaults.standard
        defaults.set(subjects, forKey: "PastpaperSubjects")
    }
    func getSavedSubjects(){
        let defaults = UserDefaults.standard
        subjects = defaults.stringArray(forKey: "PastpaperSubjects") ?? [String]()
        self.subjects.sort()
            self.tableView.reloadData()
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
 

        getSavedSubjects()
        constants.pastpaperSubjectDB.getDocument { (document, error) in
            if document != nil{
                let data = document?.data()
                
                var subjectsArray = [String]()
                for indexPath in (data?.indices)!{
                    
                    
                    subjectsArray.append(data![indexPath].value as! String)
                
                }
                
                if self.subjects != subjectsArray{
                    self.subjects = subjectsArray
                    self.saveSubjects()
                       self.subjects.sort()
                    self.tableView.reloadData()
                }
                
              
                
            }
        }
    }
    
    
    func stopLoading(check:@escaping ()-> Void){
       
          stopAnimating()
           
        
        
    }
    
    //Gets papers for the subject
    func getPapers(subjectName:String, onlythesepapers:String?){
        self.view.endEditing(true)
        searchBar.text = ""
        searchActive = false
          self.title = subjectName
        multiViewView.isHidden = false
        paperObjectList = [paperObject]()
        
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
        self.showLoading()
              print("Called here3")
        
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
                        let paper = paperObject(monthO: docs["month"] as? String, yearO: docs["year"] as? String, variantO: docs["variant"] as? String, typeO: docs["type"] as? String, url: docs["name"] as! String)
                     
                        if !self.isPaperObjectInvalid(paperObject: paper){
                     
                           
                            self.paperObjectList.append(paper)
                            
                        }
                        
                    }
                    
                }
                
                if onlythesepapers != nil{
                   self.paperObjectList = self.paperObjectList.sorted(by: { ($0.year! < $1.year!)})
                }
                self.stopLoading {
                    
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
 
        if let username_local = commonutil.getUserData(key: "username"){
            username = username_local
            
        }
        getSubjects()
        searchBar.delegate = self
        
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
   
    //Downloads paper and if multiview is selected calls download second paper method else opens pdf viewer
    func downloadPDF(paperName:String, subject:String, isItMultiview:Bool){
        
        showLoading()
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
                    self.stopLoading {
                        //TODO: Show error
                    }
                    
                } else {
                    print("Success Man: \(paperName)")
                    if !isItMultiview{
                        self.stopLoading {
                            
                        }
                        self.openPDFViewer(url: localURL,secondPaper: nil)}else{
                        self.downloadSecondPDF(paperName: self.secondSelectedPaperUrl!, subject: subject, previousPaper: localURL)
                    }
                }
            }
        }else{
            print("Success Man: \(paperName)")
            
            if !isItMultiview{
                self.stopLoading {
                    
                }
                self.openPDFViewer(url: localURL,secondPaper: nil)}else{
                self.downloadSecondPDF(paperName: secondSelectedPaperUrl!, subject: subject, previousPaper: localURL)
            }
            
        }
        
        
    }
    
    //Download's the second paper and passes the URL of the first paper to the open pdf viewer method
    func downloadSecondPDF(paperName:String, subject:String, previousPaper:URL){
        showLoading()
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
                    self.stopLoading {
                        //TODO:Show error
                    }
                    
                } else {
                    self.stopLoading {
                        //TODO:Show error
                    }
                    print("Success Man: \(paperName)")
                    
                    self.stopLoading {
                        
                    }
                    self.openPDFViewer(url: localURL,secondPaper: previousPaper)}
                //Download Second paper
            }
            
        }else{
            print("Success Man: \(paperName)")
            self.stopLoading {
                
            }
            self.openPDFViewer(url: localURL,secondPaper: previousPaper)}
        
        
        
        
    }
    //Open's PDF. Checks if MultiView is required or Single paper view.
    func openPDFViewer(url: URL, secondPaper:URL?){
        self.stopLoading {
            
            
        }
     
        if secondPaper == nil {
            let storyboard = UIStoryboard(name: "PastpapersStoryboard", bundle: nil)
            let singleView = storyboard.instantiateViewController(withIdentifier: "pdfIntent")as! PdfLoader
            singleView.url = url
            self.tableView.deselectRow(at: singlePaperSelectedRow!, animated: true)
         
            
            self.present(singleView,animated: true, completion: nil)
           
          
            
        }else{
            
            let storyboard = UIStoryboard(name: "PastpapersStoryboard", bundle: nil)
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
 filteredPaperObjects = filterSubjects(text: searchText, paperObjectArray: paperObjectList)
          
            
                searchActive = true
            
            if searchText == ""{
                searchActive = false
            }
            tableView.reloadData()
        }}
    

    func filterSubjects(text:String, paperObjectArray:[paperObject]) -> [paperObject]{
        
        var filteredPaperObjects = [paperObject]()
       
        let exclude = [String]()
        for indexPath in paperObjectArray.indices {

            let contains = commonUtil.NewfilterObjects(text: text, exclude: exclude) { (value) -> Bool in
                self.commonUtil.itContains(value: value, object: paperObjectArray[indexPath])
            }
            if contains{
                filteredPaperObjects.append(paperObjectArray[indexPath])
        

            }
        }


    
        return filteredPaperObjects

    }



    
}


