//
//  TeamViewVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 1/9/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class TeamViewVC: UITableViewController  {
    
    var yourGroups = [Group]()
    var otherGroups = [Group]()
    
     let morTeamURL = "http://www.morteam.com/api"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadGroups()
        
    }
    
    func loadGroups(){
        httpRequest(self.morTeamURL+"/groups/normal", type: "GET"){
            responseText in
            
            let yours = parseJSON(responseText)
            for(_, json):(String, JSON) in yours {
                self.yourGroups.append(Group(groupJSON: json))
            }
            
            httpRequest(self.morTeamURL+"/groups/other", type: "GET"){
                responseText2 in
                
                let others = parseJSON(responseText2)
                for(_, json):(String, JSON) in others {
                    self.otherGroups.append(Group(groupJSON: json))
                }

                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1){
            return self.yourGroups.count
        }
        else if (section == 2){
            return self.otherGroups.count
        }
        else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cell = UITableViewCell() //Why. Just why.
        cell.accessoryType = .disclosureIndicator
        if (indexPath.section == 1){
            cell.textLabel?.text = self.yourGroups[indexPath.row].name
        }
        else if (indexPath.section == 2){
            cell.textLabel?.text = self.otherGroups[indexPath.row].name
        }
        else {
            cell.textLabel?.text = "All Members"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        var groupSelected:Group? = nil
        var isAllMembers = false
        if (indexPath.section == 0){
            isAllMembers = true
        }
        else if (indexPath.section == 1){
            groupSelected = self.yourGroups[indexPath.row]
        }
        else {
            groupSelected = self.otherGroups[indexPath.row]
        }
        DispatchQueue.main.async(execute: {
            let vc: GroupVC! = self.storyboard!.instantiateViewController(withIdentifier: "Group") as! GroupVC
            
            vc.isAllMembers = isAllMembers
            if (!isAllMembers){
                vc.groupId = (groupSelected?._id)!
                vc.groupName = (groupSelected?.name)!
            }
            
            self.show(vc as UIViewController, sender: vc)
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
