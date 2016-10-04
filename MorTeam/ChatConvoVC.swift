//
//  ChatConvoVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation

class ChatConvoVC: UIViewController {
        
    var chatName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = chatName
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
