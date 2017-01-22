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
import Kingfisher

class UserProfileVC: UIViewController {
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var positionLabel: UILabel!
    
    @IBOutlet var phoneLabel: UILabel!
    
    @IBOutlet var absencesLabel: UILabel!
    
    @IBOutlet var percentLabel: UILabel!
    
    @IBOutlet var attendanceView: UIView!
    
    var user = User(_id: "", firstname: "", lastname: "", username: "", email: "", phone: "", profPicPath: "", team: "", position: "")
    
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
        
        self.phoneLabel.text = format(phoneNumber: user.phone)
        
        self.positionLabel.text = user.position.capitalized
        
        let imagePath = user.profPicPath.replacingOccurrences(of: " ", with: "%20") + "-300"
        var profPicUrl = URL(string: "http://www.morteam.com"+imagePath)
        
        if (imagePath != "/images/user.jpg-300"){
            profPicUrl = URL(string: "http://profilepics.morteam.com.s3.amazonaws.com"+imagePath.substring(from: (imagePath.index((imagePath.startIndex), offsetBy: 3))))
        }
        
        self.profilePic.kf.setImage(with: profPicUrl)
        
        
//        let request: NSMutableURLRequest = NSMutableURLRequest(url: profPicUrl!)
//        if let sid = storage.string(forKey: "connect.sid"){
//            request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
//        }
//        let mainQueue = OperationQueue.main
//        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//            if error == nil {
//                
//                let image = UIImage(data: data!)
//                
//                DispatchQueue.main.async(execute: {
//                    self.profilePic.image = image
//                })
//            }
//            else {
//                print("Error: \(error!.localizedDescription)")
//            }
//        })
//        
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = 4.2
        self.profilePic.clipsToBounds = true
        
        
        
        
    }
    
   
    
    func loadAttendance(){
        httpRequest(self.morTeamURL+"/users/id/\(self.user._id)/absences", type: "GET"){
            responseText, responseCode in
            
             DispatchQueue.main.async(execute: {
                let attendance = parseJSON(responseText)
                
                let attendanceObject = UserAttendance(objectJSON: attendance)
                
                
                self.absencesLabel.text = "Unexcused absences: " + String(attendanceObject.absences.count)
                
                var percent:Double = (Double(attendanceObject.present) / (Double(attendanceObject.absences.count) + Double(attendanceObject.present))) * 100.0
                if (attendanceObject.present == 0 && attendanceObject.absences.count == 0){
                    percent = 100.0
                }
                
                
                self.percentLabel.text = "Presence percentage: " + String(Double(round(10*percent)/10)) + "%"
                
            })
            
            
        }
        
        
    }
    //SO
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.characters.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.characters.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension String.CharacterView {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
