//
//  Chat.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Chat {
    let _id: String
    let name: String
    let isTwoPeople : Bool
    var lastMessage: String
    let updatedAt: String
    var imagePath: String
    
    init(chatJSON: JSON){
        
        self._id = String( describing: chatJSON["_id"] )
        self.isTwoPeople = chatJSON["isTwoPeople"].boolValue
        self.lastMessage = String( describing: chatJSON["messages"][0]["content"] )
        if (self.lastMessage == "null"){
            self.lastMessage = "No messages to display"
        }
        self.updatedAt = String( describing: chatJSON["updated_at"] )
        
        if (!self.isTwoPeople) {
            self.name = String(describing: chatJSON["name"])
            self.imagePath = "/images/group.png"
        }
        else {
            let otherUser = getUserOtherThanSelf(chatJSON["audience"]["users"])
            self.name = otherUser.firstname + " " + otherUser.lastname
            self.imagePath = otherUser.profPicPath + "-60"
        }
        
    }
}
