//
//  PostAnnouncementVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 9/27/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
extension String {
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString)
        //return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSString.CompareOptions.LiteralSearch, range: nil)
    }
}
class PostAnnouncementVC: UIViewController, UITextViewDelegate, SelectionDelegate {
    
    
    
    @IBOutlet var chooseAudience: UIButton!
    
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var contentBox: EditorTextView!
    
    var selectedMembers = [String]();
    var selectedGroups = [String]();
    
    let morTeamURL = "http://www.morteam.com:8080/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.editView()
    }
    
    func editView(){
        contentBox.layer.shadowRadius = 2.0
        contentBox.layer.shadowOpacity = 0.2
        self.view.backgroundColor = UIColorFromHex("#E9E9E9");
        
        self.chooseAudience.backgroundColor = UIColorFromHex("#FFC547");
        self.chooseAudience.layer.cornerRadius = 4.5
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.contentBox.allowsEditingTextAttributes = true
        
        self.contentBox.delegate = self
        
        //self.postButton.backgroundColor = UIColorFromHex("#FFC547");
        //self.postButton.layer.cornerRadius = 4.5
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = (textView.text != "")
    }
    
    func fix(html:String){
        //        function thing(str) {
//        let styleStart = str.indexOf(">", str.indexOf("<style")) + 1;
//        let styleEnd = str.indexOf("</style>");
//        let bodyStart = str.indexOf(">", str.indexOf("<body")) + 1;
//        let bodyEnd = str.lastIndexOf("</body>");
//        return '<div style="' + str.substring(styleStart, styleEnd).replace(/\n/g, "") /* escape double quote here? */ + '">' + str.substring(bodyStart, bodyEnd) + '</div>';
////    }
//        var styleStart = html.indexOf(target: ">", startIndex: html.indexOf(target: "<style")) + 1
//        var styleEnd = html.indexOf(target: "</style>")
//        var bodyStart = html.indexOf(target: ">", startIndex: html.indexOf(target: "<body")) + 1
//        var bodyEnd = html.indexOf(target: "</body>")
//        return "<div style=\"" + html.subString(styleStart, styleEnd).replace("\n", "") + "\">" + html.subString(bodyStart, bodyEnd) + "</div>";
        
    }
    
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        var text = self.contentBox.text
        
        
//        let documentAttributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
//        let htmlData = try! self.contentBox.attributedText.data(from: NSMakeRange(0, self.contentBox.attributedText.length), documentAttributes:documentAttributes)
//        if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
//            text = htmlString
//        }
//        print(text)
        
        
        
        
        httpRequest(self.morTeamURL+"/login", type: "POST", data: [
            "username": "1",
            "password": "zzz"
        ]){responseText in
            httpRequest(self.morTeamURL+"/announcements", type: "POST", data: [
                "content": (text?.replace(target:"\n",withString:"<br>"))! as String,
                "audience": [
                    "groups":self.selectedGroups,
                    "users":self.selectedMembers
                ]
            ]){responseText2 in
                print(responseText2)
            }
            
        }

    }
    
    func didFinishSelecting(groups: [String], members: [String]) {
        self.selectedMembers = members
        self.selectedGroups = groups
    }
    
    @IBAction func chooseAudienceClicked(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            let vc: ChooseAudienceVC! = self.storyboard!.instantiateViewController(withIdentifier: "ChooseAudience") as! ChooseAudienceVC
            vc.selectedMembers = self.selectedMembers
            vc.selectedGroups = self.selectedGroups
            vc.delegate = self; //This is critical
            let navController = UINavigationController(rootViewController: vc as UIViewController)
            self.present(navController, animated:true, completion: nil)
        })
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
