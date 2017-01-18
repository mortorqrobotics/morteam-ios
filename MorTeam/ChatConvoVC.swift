//
//  ChatConvoVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import Alamofire


class ChatConvoVC: JSQMessagesViewController {
        
    var chatName = String()
    var chatId = String()
    
    let storage = UserDefaults.standard
    var type = ""
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColorFromHex("#cccccc"))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColorFromHex("#FFC547"))
    var messages = [Message]()
    var profilePics = [String: UIImage]()
    var page = 0
    
    
    var typingTimer = Timer()
    
    
    let morteamURL = "http://www.morteam.com/api"
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chatName
        self.setup()
        self.loadMessages(scrollToBottom: true)
        self.setupSocketIO()
        //self.loadProfilePictures()  Uncommenting this line will cause a major memory spike unless things are changed
    }
    
    func reloadMessagesView() {
        //should i invalidate?
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView?.reloadData()
    }
    
    func setup() {
        self.title = self.chatName
        self.collectionView!.backgroundColor = UIColorFromHex("#E9E9E9")
        self.collectionView!.typingIndicatorMessageBubbleColor = UIColorFromHex("#cccccc")
        if let firstname = storage.string(forKey: "firstname"), let user_id = storage.string(forKey: "_id") {
            self.senderId = user_id
            self.senderDisplayName = firstname
        }
        
        
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero;
       
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        unreadChatIds = unreadChatIds.filter() {$0 != self.chatId}
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textView.becomeFirstResponder()
        
    }

    func loadMessages(scrollToBottom: Bool) {
        
        //This code refuses to not be a major problem
        
//        print("wants to load")
//        httpRequest(self.morteamURL+"/chats/id/"+self.chatId+"/messages?skip="+String(self.page*20), type: "GET"){responseText, responseCode in
//            
//            print("does load")
//            
//           
//            let responseMessages = parseJSON(responseText)
//            for (_, json) in responseMessages {
//                let message = Message(messageJSON: json)
//                self.messages.insert(message, at: 0)
//            }
//            DispatchQueue.main.async(execute: {
//                self.reloadMessagesView()
//                if responseMessages.count == 20 {
//                    self.showLoadEarlierMessagesHeader = true
//                }
//                self.page += 1
//                if (scrollToBottom) {
//                    self.scrollToBottom(animated: false)
//                }
//            })
//        }
        Alamofire.request(self.morteamURL+"/chats/id/"+self.chatId+"/messages?skip="+String(self.page*20)).response { response in
            
//            print("Request: \(response.request)")
//            print("Response: \(response.response)")
//            print("Error: \(response.error)")
            
            
            //Won't work?
            if let error = response.error {
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else {
                if let data = response.data, let responseDataText = String(data: data, encoding: .utf8) {
                    
                    let responseMessages = parseJSON(responseDataText)
                    
                    for (_, json) in responseMessages {
                        let message = Message(messageJSON: json)
                        self.messages.insert(message, at: 0)
                    }
                    DispatchQueue.main.async(execute: {
                        self.reloadMessagesView()
                        if responseMessages.count == 20 {
                            self.showLoadEarlierMessagesHeader = true
                        }
                        self.page += 1
                        if (scrollToBottom) {
                            self.scrollToBottom(animated: false)
                        }
                    })
                    
                    
                }
            }
            
            
        }
    }
    
//    func loadProfilePictures() {
//        httpRequest(self.morteamURL+"/chats/id/"+self.chatId+"/allMembers", type: "GET") {
//            responseText, responseCode in
//            
//            let usersJSON = parseJSON(responseText)
//            
//            var users: [User] = []
//            for (_, userJSON):(String, JSON) in usersJSON {
//                users += [User(userJSON: userJSON)]
//            }
//            
//            for user in users {
//                self.downloadImage("http://www.morteam.com"+user.profPicPath+"-60") {
//                    image in
//                    
//                    self.profilePics[user._id] = image
//                    self.reloadMessagesView()
//                }
//            }
//            
//        }
//    }
    
    func setupSocketIO() {
        SocketIOManager.sharedInstance.socket.on("message"){data, ack in
            let id = String(describing: JSON(data)[0]["chatId"])
            if id == self.chatId {
                let message = Message(messageJSONAlt: JSON(data)[0])
                self.messages += [message]
                DispatchQueue.main.async(execute: {
                    self.reloadMessagesView()
                    self.scrollToBottom(animated: false)
                })
            }
            else {
                if (!unreadChatIds.contains(id)){
                    unreadChatIds.append(id)
                }
            }
        }
        SocketIOManager.sharedInstance.socket.on("start typing"){data, ack in
            if String(describing: JSON(data)[0]["chatId"]) == self.chatId {
                //counter later?
                self.showTypingIndicator = true
                self.scrollToBottom(animated: true)
                
            }
        }
        SocketIOManager.sharedInstance.socket.on("stop typing"){data, ack in
            if String(describing: JSON(data)[0]["chatId"]) == self.chatId {
                self.showTypingIndicator = false
            }
        }
    }
    
//    func downloadImage(_ urlString: String, cb: @escaping (_ image: UIImage) -> Void ) {
//        if let url = URL(string: urlString) {
//            let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
//            if let sid = storage.string(forKey: "connect.sid"){
//                request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
//            }
//            let mainQueue = OperationQueue.main
//            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//                if error == nil {
//                    //let image = UIImage(data: data!)
//                    //cb(image!)
//                    cb(UIImage(named: "user")!)
//                    
//                }
//                else {
//                    print("Error: \(error!.localizedDescription)")
//                }
//            })
//        }else{
//            cb(UIImage(named: "user")!)
//        }
//    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = super.collectionView(super.collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[(indexPath as NSIndexPath).row]
        if !message.isMediaMessage() {
            //change font to Exo2
            cell.textView!.textColor = UIColor.black
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName : cell.textView!.textColor!,NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
            
            cell.textView.font = UIFont(name: "Exo2-Light", size: 17.0)
        }
        
        
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId_) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        let avatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: UIImage(named: "user"), diameter: 30)
        
        if let profpic = self.profilePics[message.senderId()!] {
            avatar?.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(profpic, withDiameter: 30)
            avatar?.avatarHighlightedImage = JSQMessagesAvatarImageFactory.circularAvatarImage(profpic, withDiameter: 30)
        }
        
        return avatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.row]
        let data = self.messages[(indexPath as NSIndexPath).row]
        
        if (self.senderDisplayName == data.senderDisplayName()) {
            return nil
        }
        if indexPath.row > 1 {
            let previousMessage = messages[indexPath.row - 1]
            if previousMessage.senderId() == message.senderId() {
                return nil
            }
        }
        return NSAttributedString(string: data.senderDisplayName()!)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if indexPath.row == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date())
        }
        if indexPath.row - 1 > 0 {
            let previousMessage = messages[indexPath.row - 1]
            if message.date_.timeIntervalSince(previousMessage.date_ as Date) / (60*5) > 1 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date())
            }
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.row - 1 > 0 {
            let previousMessage = self.messages[indexPath.row - 1]
            let message = self.messages[indexPath.row]
            if message.date_.timeIntervalSince(previousMessage.date_ as Date) / (60*5) > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message = messages[indexPath.row]
        
        let data = self.messages[(indexPath as NSIndexPath).row]
        if (self.senderDisplayName == data.senderDisplayName()) {
            return 0.0
        }
        if indexPath.row > 1 {
            let previousMessage = self.messages[indexPath.row - 1]
            if previousMessage.senderId() == message.senderId() {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.loadMessages(scrollToBottom: false)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let message = Message(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
        
        var msg: [String: String]
        
        msg = ["chatId": self.chatId, "content": text]

        SocketIOManager.sharedInstance.socket.emit("sendMessage", msg)

    }

   
    override func textViewDidChange(_ textView: UITextView) {
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = (self.inputToolbar.contentView.textView.text != "")
        
        if (typingTimer.isValid){
            typingTimer.invalidate()
        }
        else {
            SocketIOManager.sharedInstance.socket.emit("start typing", ["chatId":self.chatId])
        }
        typingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerDidEnd(_:)), userInfo: nil, repeats: false)
    }
    func timerDidEnd(_ timer : Timer){
        SocketIOManager.sharedInstance.socket.emit("stop typing", ["chatId":self.chatId])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SocketIOManager.sharedInstance.socket.emit("stop typing", ["chatId":self.chatId])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unreadChatIds = unreadChatIds.filter() {$0 != self.chatId} //Fixes the odd problem, revise
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        //Add something here
        //self.collectionView.collectionViewLayout.invalidateLayout()
        //self.collectionView!.reloadItems(at: [indexPath])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }

    
}
