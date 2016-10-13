//
//  Audience.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/12/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Audience {
    var users: [String]
    var groups: [String]
    
    init(audienceJSON: JSON){
        var allUsers = [String]()
        var allGroups = [String]()
        for(_, json):(String, JSON) in audienceJSON["users"] {
            allUsers.append(String(describing: json))
        }
        for(_, json):(String, JSON) in audienceJSON["groups"] {
            allGroups.append(String(describing: json))
        }
        self.users = allUsers
        self.groups = allGroups
    }
}
