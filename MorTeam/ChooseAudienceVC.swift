//
//  ChooseAudienceVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation

protocol SelectionDelegate: class {
    func didFinishSelecting(groups: [String], members: [String])
}

class ChooseAudienceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchAudienceBar: UISearchBar!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var badgesTableView: UITableView!
    var badges = [Any]();
    var showingBadges = [Any]();
    
    var selectedGroups = [String]();
    var selectedMembers = [String]();
    
    weak var delegate: SelectionDelegate? = nil
    
    let morTeamURL = "http://www.morteam.com:8080/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.editView()
        self.loadBadges()
    }
    
    func loadBadges(){
        httpRequest(self.morTeamURL+"/login", type: "POST", data: [
            "username": "1",
            "password": "azaz"
        ]){responseText in
            httpRequest(self.morTeamURL+"/groups", type: "GET"){
                responseTextGroups in
                httpRequest(self.morTeamURL+"/teams/current/users", type: "GET"){
                    responseTextUsers in

                    let groups = parseJSON(responseTextGroups)
                    
                    for(_, json):(String, JSON) in groups {
                        let group = Group(groupJSON: json)
                        self.badges.append(group)
                    }
                
                    let users = parseJSON(responseTextUsers)
                    
                    for(_, json):(String, JSON) in users {
                        let user = User(userJSON: json)
                        self.badges.append(user)
                    }
                    
                    self.showingBadges = self.badges
                    
                    DispatchQueue.main.async(execute: {
                        self.badgesTableView.reloadData()
                    })
                }
            }
            
        }
    }
    
    func editView(){
        self.navigationItem.hidesBackButton = true
    }
    
    func getGroupName(group: Group) -> String{
        if (group.__t == "NormalGroup"){
            return group.name
        }
        else if (group.__t == "AllTeamGroup"){
            return "Entire Team"
        }
        else if (group.__t == "PositionGroup"){
            if (group.position == "Alumnus"){
                return "Alumni"
            }
            else {
                return group.position.capitalized + "s"
            }
        }
        return group._id //Will never run
    }
    
    func updateTableBySearching(forText: String) {
        self.showingBadges = []
        for badge in self.badges {
            var badgeText = "";
            if (badge is Group) {
                badgeText = self.getGroupName(group: badge as! Group) + " (Group)"
            }
            else {
                badgeText = (badge as! User).firstname + " " + (badge as! User).lastname;
            }
            if (badgeText.lowercased().range(of: forText.lowercased()) != nil) {
                self.showingBadges.append(badge)
            }
        }
        DispatchQueue.main.async(execute: {
            self.badgesTableView.reloadData()
        })
    }
    
    func updateTableWithAllBadges(){
        self.showingBadges = self.badges
        DispatchQueue.main.async(execute: {
            self.badgesTableView.reloadData()
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchAudienceBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchAudienceBar.showsCancelButton = false
        self.searchAudienceBar.resignFirstResponder()
        self.searchAudienceBar.text = ""
        self.updateTableWithAllBadges()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchText == ""){
            self.updateTableWithAllBadges()
        }
        else {
            self.updateTableBySearching(forText: searchText)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchAudienceBar.showsCancelButton = false
        self.searchAudienceBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingBadges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = badgesTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BadgeTableViewCell
        let row = (indexPath as NSIndexPath).row
        let badge = self.showingBadges[row]
        if (badge is Group) {
            cell.textLabel?.text = self.getGroupName(group: badge as! Group) + " (Group)"
            cell._id = (badge as! Group)._id
            cell.type = "Group"
        }
        else {
            cell.textLabel?.text = (badge as! User).firstname + " " + (badge as! User).lastname;
            cell._id = (badge as! User)._id
            cell.type = "Member"
        }
        cell.selectionStyle = .none
        cell.accessoryType = .none
        if (selectedMembers.contains(cell._id) || selectedGroups.contains(cell._id)){
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        delegate?.didFinishSelecting(groups: self.selectedGroups, members: self.selectedMembers)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? BadgeTableViewCell {
            if (cell.accessoryType == .checkmark){
                cell.accessoryType = .none
                if (cell.type == "Member"){
                    if let index = selectedMembers.index(of: cell._id) {
                        selectedMembers.remove(at: index)
                    }
                }
                else if (cell.type == "Group"){
                    if let index = selectedGroups.index(of: cell._id) {
                        selectedGroups.remove(at: index)
                    }
                }
            }
            else{
                cell.accessoryType = .checkmark
                if (cell.type == "Member"){
                    selectedMembers.append(cell._id)
                }
                else if (cell.type == "Group"){
                    selectedGroups.append(cell._id)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
