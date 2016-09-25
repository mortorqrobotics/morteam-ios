//
//  Announcement.swift
//  MorTeam
//
//  Created by arvin zadeh on 9/25/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation


class Announcement {
    let profpicpath: String
    let content: String
    let author: JSON
    let timestamp: String
    
    init(announcementJSON: JSON){
        self.profpicpath = String(describing: announcementJSON["profpicpath"])
        self.content = String(describing: announcementJSON["content"])
        self.author = announcementJSON["author"]
        self.timestamp = String(describing: announcementJSON["timestamp"])
    }
}
