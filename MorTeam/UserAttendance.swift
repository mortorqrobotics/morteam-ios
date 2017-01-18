//
//  UserAttendance.swift
//  MorTeam
//
//  Created by arvin zadeh on 1/17/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import Foundation

class UserAttendance {
    
    var absences: [Event]
    var present: Int
    
    init(objectJSON: JSON){
        var objects = [Event]()
        self.present = Int(String(describing: objectJSON["present"]))!
        for(_, json):(String, JSON) in objectJSON["absences"] {
            objects.append(Event(eventJSON: json))
        }
        self.absences = objects
    }
}
