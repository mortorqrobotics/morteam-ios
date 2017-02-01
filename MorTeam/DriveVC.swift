//
//  DriveVC.swift
//  MorTeam
//
//  Created by Arvin Zadeh on 1/31/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import UIKit
import Foundation

class DriveVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var showingFolders = [Folder]()
    var allFolders = [Folder]()
    
    @IBOutlet weak var folderTableView: UITableView!
    
    @IBOutlet weak var searchFoldersBar: UISearchBar!
    let morTeamURL = "http://www.morteam.com/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadFolders()
    }
    
    func loadFolders(){
        httpRequest(self.morTeamURL+"/folders", type: "GET"){responseText, responseCode in
            
            self.showingFolders = []
            self.allFolders = []
            let foldersJSON = parseJSON(responseText)
            
            for(_, subJson):(String, JSON) in foldersJSON {
                self.allFolders += [Folder(folderJSON: subJson)]
            }
            
            self.showingFolders = self.allFolders
            
            DispatchQueue.main.async(execute: {
                self.folderTableView.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingFolders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.folderTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DriveFolderTableViewCell
        
        cell.nameLabel.text = self.showingFolders[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        folderTableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async(execute: {
            let vc: FilesVC! = self.storyboard!.instantiateViewController(withIdentifier: "Files") as! FilesVC
            let row = (indexPath as NSIndexPath).row
            vc.folder = self.showingFolders[row] 
            self.show(vc as UIViewController, sender: vc)
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = false
        searchBar.text = "";
        searchBar.resignFirstResponder()
        DispatchQueue.main.async(execute: {
            self.showingFolders = self.allFolders
            self.folderTableView.reloadData()
        })
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.showingFolders = self.allFolders.filter() {$0.name.lowercased().contains(searchText.lowercased())}
        DispatchQueue.main.async(execute: {
            self.folderTableView.reloadData()
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchFoldersBar.resignFirstResponder()
    }


}
