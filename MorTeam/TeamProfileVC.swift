//
//  TeamProfileVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 6/22/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class TeamProfileVC: UIViewController {
        
    var teamNumber = Int(); //Gets value from MapViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Team " + String(teamNumber) + " Profile"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


