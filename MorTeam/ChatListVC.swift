//
//  ChatListVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation

class ChatListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var searchChatsBar: UISearchBar!
    @IBOutlet var chatListTableView: UITableView!
    @IBOutlet var newChatButton: UIBarButtonItem!
    
    var chats = [Any]()
    
    let morTeamURL = "http://www.morteam.com:8080/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.getChats()
        
    }
    
    func getChats() {
        httpRequest(self.morTeamURL+"/chats", type: "GET"){
            responseText in
            
            self.chats = []
            let newChats = parseJSON(responseText)
            print(responseText)
            for(_, subJson):(String, JSON) in newChats {
                self.chats += [Chat(chatJSON: subJson)]
            }
            
            DispatchQueue.main.async(execute: {
                self.chatListTableView.reloadData()
            })
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchChatsBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchChatsBar.showsCancelButton = false
        self.searchChatsBar.resignFirstResponder()
        self.searchChatsBar.text = ""
        //self.updateTableWithAllBadges()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchText == ""){
            //self.updateTableWithAllBadges()
        }
        else {
            //self.updateTableBySearching(forText: searchText)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchChatsBar.showsCancelButton = false
        self.searchChatsBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        let row = (indexPath as NSIndexPath).row
        let chat = self.chats[row] as! Chat
        cell.textLabel?.text = chat.name
        return cell
    }

    @IBAction func newChatButtonClicked(_ sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
