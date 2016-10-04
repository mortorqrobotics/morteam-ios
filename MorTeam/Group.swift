//
//  Group.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
class Group {
    let _id: String
    let __t: String
    let name: String
    let position: String
   
    
    init(groupJSON: JSON){
        self._id = String( describing: groupJSON["_id"] )
        self.__t = String( describing: groupJSON["__t"] )
        self.name = String( describing: groupJSON["name"] )
        self.position = String( describing: groupJSON["position"] )
    }
}
