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
    let team: String?
    let profPicPath: String
    let groups: [String]? //maybe populate later, how to make optional
    
    init(userJSON: JSON){
        var allGroupIds = [String]()
        self._id = String( describing: userJSON["_id"] )
        self.firstname = String( describing: userJSON["firstname"] )
        self.lastname = String( describing: userJSON["lastname"] )
        self.username = String( describing: userJSON["username"] )
        self.team = String( describing: userJSON["team"] )
        self.email = String( describing: userJSON["email"] )
        self.phone = String( describing: userJSON["phone"] )
        self.profPicPath = String( describing: userJSON["profpicpath"] )
        for(_, json):(String, JSON) in userJSON["groups"] {
            allGroupIds.append(String(describing: json))
        }
        self.groups = allGroupIds
    }
    init(_id: String, firstname: String, lastname: String, username: String, email: String, phone: String, profPicPath: String, team: String){
        self._id = _id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.team = team
        self.email = email
        self.phone = phone
        self.profPicPath = profPicPath
        self.groups = [String]() //hmm
    }
}
