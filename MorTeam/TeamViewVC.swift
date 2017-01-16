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
        
        
    }
    
    @IBAction func logoutButtonClicked(_ sender: AnyObject) {
        
        logout()
        DispatchQueue.main.async(execute: {
            let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "login")
            self.present(vc as! UIViewController, animated: true, completion: nil)
            
            
        })
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //Don't try putting this in viewWillAppear because the table is not yet loaded and it will crash
        self.loadGroups()
    }
    
    func loadGroups(){
        httpRequest(self.morTeamURL+"/groups/normal", type: "GET"){
            responseText, responseCode in
            
            self.yourGroups = []
            self.otherGroups = []
            
            let yours = parseJSON(responseText)
            for(_, json):(String, JSON) in yours {
                self.yourGroups.append(Group(groupJSON: json))
            }
            
            httpRequest(self.morTeamURL+"/groups/other", type: "GET"){
                responseText2, responseCode in
                
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
        
        let vc: GroupVC! = self.storyboard!.instantiateViewController(withIdentifier: "Group") as! GroupVC
        var groupSelected:Group? = nil
        vc.isAllMembers = false
        if (indexPath.section == 0){
            //Done here for speed
            vc.isAllMembers = true
            vc.groupName = "All Members"
            vc.isInGroup = true //Technically
        }
        else if (indexPath.section == 1){
            groupSelected = self.yourGroups[indexPath.row]
            vc.isInGroup = true
        }
        else {
            groupSelected = self.otherGroups[indexPath.row]
            vc.isInGroup = false
        }
        
        if (!vc.isAllMembers){
            vc.groupId = (groupSelected?._id)!
            vc.groupName = (groupSelected?.name)!
        }
        DispatchQueue.main.async(execute: {
            self.show(vc as UIViewController, sender: vc)
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
