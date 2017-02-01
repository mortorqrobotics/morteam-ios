//
//  FilesVC.swift
//  MorTeam
//
//  Created by Arvin Zadeh on 1/31/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class FilesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var folder: Folder? = nil
    
    @IBOutlet weak var searchFilesSearchBar: UISearchBar!
    @IBOutlet weak var filesTableView: UITableView!
    var allFiles = [File]()
    var showingFiles = [File]()
    
    let morTeamURL = "http://www.morteam.com/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = folder!.name
        self.loadFiles()
        
    }
    
    func loadFiles(){
        httpRequest(self.morTeamURL+"/folders/id/"+(self.folder?._id)!+"/files", type: "GET"){responseText, responseCode in
            
            self.showingFiles = []
            self.allFiles = []
            let filesJSON = parseJSON(responseText)
            
            for(_, subJson):(String, JSON) in filesJSON {
                self.allFiles += [File(fileJSON: subJson)]
            }
            
            self.showingFiles = self.allFiles
            
            DispatchQueue.main.async(execute: {
                self.filesTableView.reloadData()
            })
            
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.filesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileTableViewCell
        
        cell.name.text = self.showingFiles[indexPath.row].name
        cell.originalName.text = self.showingFiles[indexPath.row].originalName
        cell.fileImage.image = UIImage(imageLiteralResourceName: self.showingFiles[indexPath.row].type)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filesTableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.openURL(NSURL(string: "http://www.morteam.com/api/files/id/"+self.showingFiles[indexPath.row]._id)! as URL)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = false
        searchBar.text = "";
        searchBar.resignFirstResponder()
        DispatchQueue.main.async(execute: {
            self.showingFiles = self.allFiles
            self.filesTableView.reloadData()
        })
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.showingFiles = self.allFiles.filter() {$0.name.lowercased().contains(searchText.lowercased())}
        DispatchQueue.main.async(execute: {
            self.filesTableView.reloadData()
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchFilesSearchBar.resignFirstResponder()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }





}
