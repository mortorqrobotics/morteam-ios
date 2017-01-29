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
    
    @IBOutlet var chatNameBox: LoginTextField!
    @IBOutlet var composeChatButton: UIBarButtonItem!
    var selectedMembers = [String]()
    var selectedGroups = [String]()
    
    var storage = UserDefaults.standard
    
    let morTeamURL = "http://test.voidpigeon.com/api"
    
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
    
    

    @IBAction func composeChatButtonClicked(_ sender: AnyObject) {
        
        self.selectedMembers = self.selectedMembers.filter() {$0 != storage.string(forKey: "_id")}
        
        if (self.selectedGroups.count == 0 && self.selectedMembers.count == 1){
            
            httpRequest(self.morTeamURL+"/chats", type: "POST", data: [
                "isTwoPeople": true,
                "otherUser": self.selectedMembers[0]
            ]){responseText, responseCode in
                
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                

            }
            
        }
        else {
            httpRequest(self.morTeamURL+"/chats", type: "POST", data: [
                "isTwoPeople": false,
                "name": self.chatNameBox.text!,
                "audience":[
                    "users": self.selectedMembers,
                    "groups": self.selectedGroups
                ]
            ]){responseText, responseCode in

                
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                
            }
        }
        
        
        
        
    }
    
    func didFinishSelecting(groups: [String], members: [String]) {
        self.selectedMembers = members
        self.selectedGroups = groups
        
        self.selectedMembers = self.selectedMembers.filter() {$0 != storage.string(forKey: "_id")}
        
        if (self.selectedGroups.count > 0 || self.selectedMembers.count > 1){
            DispatchQueue.main.async(execute: {
                self.chatNameBox.isHidden = false
            })
        }
        else {
            DispatchQueue.main.async(execute: {
                self.chatNameBox.isHidden = true
            })
        }
        
        
        if (self.selectedGroups.count > 0 || self.selectedMembers.count > 0){
            self.composeChatButton.isEnabled = true
        }
        else {
            self.composeChatButton.isEnabled = false
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

