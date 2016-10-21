//
//  AddEventVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class AddEventVC: UIViewController, SelectionDelegate {
    
    @IBOutlet var chooseAudienceButton: UIButton!
    
    @IBOutlet var eventNameBox: UITextView!
    
    @IBOutlet var eventDescriptionBox: UITextView!
    
    var selectedMembers = [String]();
    var selectedGroups = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }
    
    func setup() {
        self.view.backgroundColor = UIColorFromHex("#E9E9E9");
        self.chooseAudienceButton.backgroundColor = UIColorFromHex("#FFC547");
        self.chooseAudienceButton.layer.cornerRadius = 4.5
        
    }
    @IBAction func chooseAudienceButtonClicked(_ sender: AnyObject) {
        
        DispatchQueue.main.async(execute: {
            let vc: ChooseAudienceVC! = self.storyboard!.instantiateViewController(withIdentifier: "ChooseAudience") as! ChooseAudienceVC
            vc.selectedMembers = self.selectedMembers
            vc.selectedGroups = self.selectedGroups
            vc.delegate = self;
            let navController = UINavigationController(rootViewController: vc as UIViewController)
            self.present(navController, animated:true, completion: nil)
        })
        
    }
    
    func didFinishSelecting(groups: [String], members: [String]) {
        self.selectedMembers = members
        self.selectedGroups = groups
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
