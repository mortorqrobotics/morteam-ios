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
    var showingChats = [Any]()
    
    let morTeamURL = "http://www.morteam.com:8080/api"
    
    var imageCache = [String:UIImage]()
    
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

            for(_, subJson):(String, JSON) in newChats {
                self.chats += [Chat(chatJSON: subJson)]
            }
            self.showingChats = self.chats
            DispatchQueue.main.async(execute: {
                self.chatListTableView.reloadData()
            })
            
        }
    }
    
    func updateTableWithAllChats() {
        self.showingChats = self.chats
        DispatchQueue.main.async(execute: {
            self.chatListTableView.reloadData()
        })
    }
    
    func updateTableBySearching(forText: String){
        self.showingChats = []
        for chat in self.chats {
            if ((chat as! Chat).name.lowercased().range(of: forText.lowercased()) != nil) {
                self.showingChats.append(chat)
            }
        }
        DispatchQueue.main.async(execute: {
            self.chatListTableView.reloadData()
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchChatsBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchChatsBar.showsCancelButton = false
        self.searchChatsBar.resignFirstResponder()
        self.searchChatsBar.text = ""
        self.updateTableWithAllChats()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchText == ""){
            self.updateTableWithAllChats()
        }
        else {
            self.updateTableBySearching(forText: searchText)
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
        return self.showingChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatListCell
        
        cell.accessoryType = .disclosureIndicator
        
        let row = (indexPath as NSIndexPath).row
        let chat = self.showingChats[row] as! Chat
        cell.name.text = chat.name
        cell.lastMessage.text = chat.lastMessage
        
        let imagePath = (self.chats[row] as! Chat).imagePath.replacingOccurrences(of: " ", with: "%20")
        let profPicUrl = URL(string: "http://www.morteam.com:8080"+imagePath)
        
        //Fix this mess with KF
        if let img = self.imageCache[imagePath] {
            cell.profilePic.image = img
        }else{
            let request: NSMutableURLRequest = NSMutableURLRequest(url: profPicUrl!)
            if let sid = storage.string(forKey: "connect.sid"){
                request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
            }
            let mainQueue = OperationQueue.main
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    
                    let image = UIImage(data: data!)
                    
                    self.imageCache[imagePath] = image
                    
                    DispatchQueue.main.async(execute: {
                        cell.profilePic.image = image
                    })
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        }
        

        cell.profilePic.layer.masksToBounds = false
        cell.profilePic.layer.cornerRadius = 4.2
        cell.profilePic.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatListTableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async(execute: {
            let vc: ChatConvoVC! = self.storyboard!.instantiateViewController(withIdentifier: "ChatConvo") as! ChatConvoVC
            let row = (indexPath as NSIndexPath).row
            let chat = self.showingChats[row] as! Chat
            vc.chatName = chat.name
            vc.chatId = chat._id
            self.show(vc as UIViewController, sender: vc)
        })
    }

    @IBAction func newChatButtonClicked(_ sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
