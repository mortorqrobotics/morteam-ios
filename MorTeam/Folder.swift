//
//  Folder.swift
//  MorTeam
//
//  Created by Arvin Zadeh on 1/31/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import Foundation
class Folder {

    let name: String
    let _id: String
    
    init(folderJSON: JSON){
        self.name = String( describing: folderJSON["name"] )
        self._id = String( describing: folderJSON["_id"] )
    }
}
