//
//  ComposeChatVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 10/5/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation

class ComposeChatVC: UIViewController, SelectionDelegate {
    
    
    @IBOutlet var chooseAudienceButton: UIButton!
    
    var selectedMembers = [String]()
    var selectedGroups = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        
    }
    func setup(){
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
        // Dispose of any resources that can be recreated.
    }
    
    
}

