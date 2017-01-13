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
    var onlineUsers = [String]()
    
    let morTeamURL = "http://www.morteam.com/api"
    
    var imageCache = [String:UIImage]()
    var isGettingChats = false //To avoid double getChats() 
    var isLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setupSocketIO()
        getChats(update: true)
        
       
    }

    override func viewWillAppear(_ animated: Bool) {
        if (isLoad){
            isLoad = false
        }
        else {
            getClientsAndGetChats()
        }
    }
    
    func getClientsAndGetChats(){
        SocketIOManager.sharedInstance.socket.emit("get clients")
    }
    
    func getChats(update: Bool) {
        if (!isGettingChats){
            isGettingChats = true
            httpRequest(self.morTeamURL+"/chats", type: "GET"){responseText in
                
                self.chats = []
                let newChats = parseJSON(responseText)

                for(_, subJson):(String, JSON) in newChats {
                    self.chats += [Chat(chatJSON: subJson)]
                }
                print(self.chats)
                if (self.searchChatsBar.text != ""){
                    self.updateTableBySearching(forText: self.searchChatsBar.text!)
                }
                else {
                    self.updateTableWithAllChats()
                }
                self.isGettingChats = false
                if (update){
                    self.getClientsAndGetChats()
                }
            }
        }
    }
    
    func updateTableWithAllChats() {
        self.showingChats = self.chats
        DispatchQueue.main.async(execute: {
            self.chatListTableView.reloadData()
        })
    }
    
    func setupSocketIO() {
        
        SocketIOManager.sharedInstance.socket.on("message"){data, ack in
            let id = String(describing: JSON(data)[0]["chatId"])
            if (!unreadChatIds.contains(id)){
                unreadChatIds.append(id)
            }
            self.getChats(update: false)
        }
        
        SocketIOManager.sharedInstance.socket.on("get clients"){data, ack in
            self.onlineUsers = data[0] as! [String]
            self.getChats(update: false) //Revise
        }
        
        
        SocketIOManager.sharedInstance.socket.on("joined"){data, ack in
            let id = String(describing: JSON(data)[0]["_id"])
            self.onlineUsers.append(id)
            self.getChats(update: false)
        }
        
        SocketIOManager.sharedInstance.socket.on("left"){data, ack in
            let id = String(describing: JSON(data)[0]["_id"])
            self.onlineUsers = self.onlineUsers.filter() {$0 != id}
            self.getChats(update: false)
        }
        
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
        cell.lastMessage.text = chat.lastMessage
        
        let imagePath = (self.chats[row] as! Chat).imagePath.replacingOccurrences(of: " ", with: "%20")
        let profPicUrl = URL(string: "http://www.morteam.com"+imagePath)
        
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
        if (chat.isTwoPeople){
            cell.profilePic.layer.borderColor = UIColor.red.cgColor
            cell.profilePic.layer.borderWidth = 3.0
            if (self.onlineUsers.contains(chat.otherUserId!)){
                cell.profilePic.layer.borderColor = UIColor.green.cgColor
            }
        }
        else {
            cell.profilePic.layer.borderWidth = 0.0
        }
        
        
        cell.name.font = UIFont(name: "Exo2-Regular", size: 17.0)
        cell.lastMessage.font = UIFont(name: "Exo2-Light", size: 13.0)
        cell.name.text = chat.name
        if (unreadChatIds.contains(chat._id)){
            cell.name.font = UIFont(name: "Exo2-SemiBold", size: 17.0)
            cell.lastMessage.font = UIFont(name: "Exo2-SemiBold", size: 13.0)
            cell.name.text = chat.name + " (New Messages)"
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
            vc.hidesBottomBarWhenPushed = true
            self.show(vc as UIViewController, sender: vc)
        })
    }

    @IBAction func newChatButtonClicked(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            let vc: ComposeChatVC! = self.storyboard!.instantiateViewController(withIdentifier: "ComposeChat") as! ComposeChatVC
            self.show(vc as UIViewController, sender: vc)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
