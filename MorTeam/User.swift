//
//  User.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class User {
    let _id: String
    let firstname: String
    let lastname: String
    let username: String
    let email: String
    let phone: String
    let profPicPath: String
    
    init(userJSON: JSON){
        self._id = String( describing: userJSON["_id"] )
        self.firstname = String( describing: userJSON["firstname"] )
        self.lastname = String( describing: userJSON["lastname"] )
        self.username = String( describing: userJSON["username"] )
        self.email = String( describing: userJSON["email"] )
        self.phone = String( describing: userJSON["phone"] )
        self.profPicPath = String( describing: userJSON["profpicpath"] )
    }
    init(_id: String, firstname: String, lastname: String, username: String, email: String, phone: String, profPicPath: String){
        self._id = _id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.email = email
        self.phone = phone
        self.profPicPath = profPicPath
    }
}
