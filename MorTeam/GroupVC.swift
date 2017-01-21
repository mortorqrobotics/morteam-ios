
//
//  GroupVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 1/13/17.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class GroupVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var groupId = String()
    var groupName = String()
    var isAllMembers = Bool()
    var isInGroup = Bool()
    
    var storage = UserDefaults.standard
    
    
    @IBOutlet var userTable: UITableView!
    
    @IBOutlet var searchUsersBar: UISearchBar!
    
    var showingUsers = [User]()
    var users = [User]()
    
//    var imageCache = [String:UIImage]()
    
    let morTeamURL = "http://www.morteam.com/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadUsers()
        
    }
    
    //   /groups/normal/id/:groupId/join POST
    //   /groups/normal/id/:groupId/users/id/:userId DELETE
    
    
    
    
    func joinGroupButtonClicked(_ sender: UIBarButtonItem) {
        httpRequest(self.morTeamURL+"/groups/normal/id/\(self.groupId)/join", type: "POST"){
            responseText, responseCode in
            DispatchQueue.main.async(execute: {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave Group", style: .done, target: self, action: #selector(GroupVC.leaveGroupButtonClicked(_:)))
            })
        }
    }
    
    func leaveGroupButtonClicked(_ sender: UIBarButtonItem) {
        httpRequest(self.morTeamURL+"/groups/normal/id/\(self.groupId)/users/id/\(self.storage.string(forKey: "_id")!)", type: "DELETE"){
            responseText, responseCode in
            DispatchQueue.main.async(execute: {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join Group", style: .done, target: self, action: #selector(GroupVC.joinGroupButtonClicked(_:)))
            })
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.isAllMembers){
            //Essentially hides it
            self.navigationItem.rightBarButtonItem?.title = ""
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        if (self.isInGroup && !self.isAllMembers){
            DispatchQueue.main.async(execute: {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave Group", style: .done, target: self, action: #selector(GroupVC.leaveGroupButtonClicked(_:)))
            })
        }
        else if (!self.isInGroup){
            DispatchQueue.main.async(execute: {
               self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join Group", style: .done, target: self, action: #selector(GroupVC.joinGroupButtonClicked(_:)))
            })
        }
        self.title = self.groupName
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }

    func loadUsers() {
        var path = "/groups/normal/id/\(self.groupId)/users"
        
        if (self.isAllMembers){
            path = "/teams/current/users"
        }
        
        httpRequest(self.morTeamURL+path, type: "GET"){
                responseText, responseCode in
            
            self.users = []
            self.showingUsers = []
            
            let users = parseJSON(responseText)
            for(_, json):(String, JSON) in users {
                self.users.append(User(userJSON: json))
            }
            
            self.showingUsers = self.users
            
            DispatchQueue.main.async(execute: {
                self.userTable.reloadData()
            })
            
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserItemCell
        
        cell.nameLabel?.text = self.showingUsers[indexPath.row].firstname + " " + self.showingUsers[indexPath.row].lastname
        
        cell.accessoryType = .disclosureIndicator
        
        let row = (indexPath as NSIndexPath).row
        
        let imagePath = self.showingUsers[row].profPicPath.replacingOccurrences(of: " ", with: "%20") + "-60"
        
        var profPicUrl = URL(string: "http://www.morteam.com"+imagePath)
        
        if (imagePath != "/images/user.jpg-60"){
            profPicUrl = URL(string: "http://profilepics.morteam.com.s3.amazonaws.com"+imagePath.substring(from: (imagePath.index((imagePath.startIndex), offsetBy: 3))))
        }
        
        cell.profilePic.kf.setImage(with: profPicUrl)
        
        
        //Fix
//        if let img = self.imageCache[imagePath] {
//            cell.profilePic.image = img
//        }
//        else {
//            let request: NSMutableURLRequest = NSMutableURLRequest(url: profPicUrl!)
//            if let sid = storage.string(forKey: "connect.sid"){
//                request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
//            }
//            let mainQueue = OperationQueue.main
//            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//                if error == nil {
//                    
//                    let image = UIImage(data: data!)
//                    
//                    self.imageCache[imagePath] = image
//                    
//                    DispatchQueue.main.async(execute: {
//                        cell.profilePic.image = image
//                    })
//                }
//                else {
//                    print("Error: \(error!.localizedDescription)")
//                }
//            })
//        }
        
        cell.profilePic.layer.masksToBounds = false
        cell.profilePic.layer.cornerRadius = 4.2
        cell.profilePic.clipsToBounds = true
        
        return cell as UITableViewCell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchUsersBar.showsCancelButton = true
    }
    
    func updateTableWithAllBadges(){
        self.showingUsers = self.users
        DispatchQueue.main.async(execute: {
            self.userTable.reloadData()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchUsersBar.showsCancelButton = false
        self.searchUsersBar.resignFirstResponder()
        self.searchUsersBar.text = ""
        self.updateTableWithAllBadges()
    }
    
    func updateTableBySearching(forText: String) {
        self.showingUsers = []
        for user in self.users {
            var userText = "";
            userText = user.firstname + " " + user.lastname
            
            if (userText.lowercased().range(of: forText.lowercased()) != nil) {
                self.showingUsers.append(user)
            }
        }
        DispatchQueue.main.async(execute: {
            self.userTable.reloadData()
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchUsersBar.showsCancelButton = false
        self.searchUsersBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchText == ""){
            self.updateTableWithAllBadges()
        }
        else {
            self.updateTableBySearching(forText: searchText)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.userTable.deselectRow(at: indexPath, animated: true)
        
        
        let user = self.showingUsers[indexPath.row]
        
        
        DispatchQueue.main.async(execute: {
            let vc: UserProfileVC! = self.storyboard!.instantiateViewController(withIdentifier: "User") as! UserProfileVC
            
            vc.user = user
            
            self.show(vc as UIViewController, sender: vc)
        })
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


