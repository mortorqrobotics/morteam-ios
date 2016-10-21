//
//  AddEventVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class AddEventVC: UIViewController {
    
    @IBOutlet var chooseAudienceButton: UIButton!
    
    @IBOutlet var eventNameBox: UITextView!
    
    @IBOutlet var eventDescriptionBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }
    
    func setup() {
        self.view.backgroundColor = UIColorFromHex("#E9E9E9");
        self.chooseAudienceButton.backgroundColor = UIColorFromHex("#FFC547");
        self.chooseAudienceButton.layer.cornerRadius = 4.5
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
