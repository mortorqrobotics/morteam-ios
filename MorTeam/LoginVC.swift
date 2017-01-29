//
//  LoginVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 1/15/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps


class LoginTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

class LoginVC: UIViewController {
    
    @IBOutlet var usernameBox: UITextField!
    
    @IBOutlet var passwordBox: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    var storage = UserDefaults.standard
    
    let morTeamURL = "http://test.voidpigeon.com/api"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColorFromHex("#FFC547");
        
    }
    
    @IBAction func loginButtonClicked(_ sender: AnyObject) {
        
        loginButton.isEnabled = false
        
        
        httpRequest(self.morTeamURL+"/login", type: "POST", data: [
            "username": self.usernameBox.text!,
            "password": self.passwordBox.text!,
            "rememberMe": true,
            "mobileDeviceToken": self.storage.string(forKey: "deviceToken") ?? nil
        ]){responseText, responseCode in
            if (responseCode > 199 && responseCode < 300){
                
                if let team = User(userJSON: parseJSON(responseText)).team {
                    
                    self.storage.set(User(userJSON: parseJSON(responseText))._id, forKey: "_id")
                    self.storage.set(User(userJSON: parseJSON(responseText)).firstname, forKey: "firstname")
                    self.storage.set(User(userJSON: parseJSON(responseText)).lastname, forKey: "lastname")
                    
                    SocketIOManager.sharedInstance.connectSocket()
                    
                    
                    DispatchQueue.main.async(execute: {
                        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "main")
                        self.show(vc as! UIViewController, sender: vc)
                    })
                    
                }
                else {
                    alert(title: "No Team For User", message: "This user is not associated with a team", buttonText: "OK", viewController: self)
                    
                    self.loginButton.isEnabled = true
                }
                
                
            }
            else {
                alert(title: "Failed Login", message: "Please try again", buttonText: "OK", viewController: self)
                
                self.loginButton.isEnabled = true
            }
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
