//
//  Message.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class Message : NSObject, JSQMessageData{
    
    let senderId_ : String!
    let senderDisplayName_ : String!
    let date_ : Date
    let isMediaMessage_ : Bool
    var text_ : String!
    let messageHash_ : UInt
    
    init(messageJSON: JSON){
        
        let author = User(userJSON: messageJSON["author"])
        let content = String( describing: messageJSON["content"] )
        let timestamp = String( describing: messageJSON["timestamp"] )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: timestamp)
        
        self.senderId_ = author._id
        self.senderDisplayName_ = author.firstname
        self.date_ = date!
        self.isMediaMessage_ = false
        self.text_ = content
        self.messageHash_ = UInt(abs(self.senderId_.hash ^ (self.date_ as NSDate).hash ^ self.text_.hash))
    }
    
    init(messageJSONAlt: JSON){
        
        let authorFirstname = String(describing: messageJSONAlt["message"]["author"]["firstname"])
        let author_id = String(describing: messageJSONAlt["message"]["author"]["_id"])
        let content = String(describing: messageJSONAlt["message"]["content"])
        let timestamp = String(describing: messageJSONAlt["message"]["timestamp"])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: timestamp)
        
        self.senderId_ = author_id
        self.senderDisplayName_ = authorFirstname
        self.date_ = date!
        self.isMediaMessage_ = false
        self.text_ = content
        self.messageHash_ = UInt(abs(self.senderId_.hash ^ (self.date_ as NSDate).hash ^ self.text_.hash))
        
    }
    
    init(senderId: String, senderDisplayName: String, date: Date, text: String){
        
        self.senderId_ = senderId
        self.senderDisplayName_ = senderDisplayName
        self.date_ = date
        self.isMediaMessage_ = false
        self.text_ = text
        self.messageHash_ = UInt(abs(self.senderId_.hash ^ (self.date_ as NSDate).hash ^ self.text_.hash))
    }
    
    @objc func senderId() -> String? {
        return senderId_
    }
    
    @objc func senderDisplayName() -> String? {
        return senderDisplayName_
    }
    
    @objc func date() -> Date? {
        return date_
    }
    
    @objc func isMediaMessage() -> Bool {
        return isMediaMessage_
    }
    
    @objc func text() -> String? {
        return text_
    }
    
    func messageHash() -> UInt {
        return messageHash_
    }
}
