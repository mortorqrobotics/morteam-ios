//
//  UserProfileVC.swift
//  MorTeam
//
//  Created by arvin zadeh on 1/16/17.
//  Copyright © 2017 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class UserProfileVC: UIViewController {
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var positionLabel: UILabel!
    
    @IBOutlet var phoneLabel: UILabel!
    
    @IBOutlet var absencesLabel: UILabel!
    
    @IBOutlet var percentLabel: UILabel!
    
    @IBOutlet var attendanceView: UIView!
    
    
    var user = User(_id: "", firstname: "", lastname: "", username: "", email: "", phone: "", profPicPath: "", team: "")
    
    let morTeamURL = "http://www.morteam.com/api"
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadAttendance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        self.view.backgroundColor = UIColorFromHex("#E9E9E9")
        
        self.title = user.firstname + " " + user.lastname + "'s Profile"
        
        self.nameLabel.text = user.firstname + " " + user.lastname
        
        self.emailLabel.text = user.email
        
        self.phoneLabel.text = user.phone
        
        //Make better
        let imagePath = user.profPicPath.replacingOccurrences(of: " ", with: "%20") + "-300"
        let profPicUrl = URL(string: "http://www.morteam.com"+imagePath)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: profPicUrl!)
        if let sid = storage.string(forKey: "connect.sid"){
            request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
        }
        let mainQueue = OperationQueue.main
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async(execute: {
                    self.profilePic.image = image
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = 4.2
        self.profilePic.clipsToBounds = true
        
        //self.positionLabel.text = user.
        
        
        
    }
    
    func loadAttendance(){
        httpRequest(self.morTeamURL+"/users/id/\(self.user._id)/absences", type: "GET"){
            responseText, responseCode in
            
             DispatchQueue.main.async(execute: {
                let attendance = parseJSON(responseText)
                
                let attendanceObject = UserAttendance(objectJSON: attendance)
                
                
                self.absencesLabel.text = "Unexcused absences: " + String(attendanceObject.absences.count)
                
                let percent:Double = (Double(attendanceObject.present) / (Double(attendanceObject.absences.count) + Double(attendanceObject.present))) * 100.0
                
                self.percentLabel.text = "Presence percentage: " + String(Double(round(10*percent)/10)) + "%"
                
            })
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
