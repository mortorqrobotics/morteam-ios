//
//  Attendance.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/12/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class AttendanceObject {
    let user: String
    let status: String

    init(objectJSON: JSON){
        self.user = String(describing: objectJSON["user"])
        self.status = String(describing: objectJSON["status"])
    }
}
