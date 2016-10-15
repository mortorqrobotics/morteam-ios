//
//  Event.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/12/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Event {
    let _id: String
    let name: String
    let description: String
    let audience: Audience
    let date: String
    let day: Int //Very helpful
    var attendance: [AttendanceObject]
    
    init(eventJSON: JSON){
        self._id = String(describing: eventJSON["_id"])
        self.name = String(describing: eventJSON["name"])
        self.description = String(describing: eventJSON["description"])
        self.audience = Audience(audienceJSON: eventJSON["audience"])
        self.date = String(describing: eventJSON["date"])
        var allAttendance = [AttendanceObject]()
        for(_, json):(String, JSON) in eventJSON["attendance"] {
            allAttendance.append(AttendanceObject(objectJSON: json))
        }
        self.attendance = allAttendance
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "UTC")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = formatter.date(from: self.date)
        let day = NSCalendar.current.component(.day, from: date!)
        
        self.day = day
        
    }
}
