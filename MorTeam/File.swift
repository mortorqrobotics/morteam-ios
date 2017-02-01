//
//  File.swift
//  MorTeam
//
//  Created by Arvin Zadeh on 1/31/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import Foundation
class File {
    
    let name: String
    let _id: String
    let originalName: String
    let type: String
    
    init(fileJSON: JSON){
        self.name = String( describing: fileJSON["name"] )
        self._id = String( describing: fileJSON["_id"] )
        self.originalName = String( describing: fileJSON["originalName"] )
        self.type = String( describing: fileJSON["type"] )
    }
}
