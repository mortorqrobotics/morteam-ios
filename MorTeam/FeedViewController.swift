//
//  MapViewController.swift
//  MorTeam
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var announcementCollectionView: UICollectionView!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    var storage = UserDefaults.standard
    var announcements = [Announcement]()
    let cellIdentifier = "AnnouncementCell"
    var imageCache = [String:UIImage]()
    let screenSize: CGRect = UIScreen.main.bounds
    var page = 0;
    var isRefreshing = false;
    var refreshControl: UIRefreshControl!
    
    
    
    let morTeamURL = "http://www.morteam.com:8080/api"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup();
        self.getAnnouncements();

    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    func setup() {
        self.view.backgroundColor = UIColorFromHex("#E9E9E9");
        self.refreshControl = UIRefreshControl();
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        self.refreshControl.addTarget(self, action: #selector(FeedViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.announcementCollectionView.addSubview(refreshControl)
    }
    
    func getAnnouncements() {
        httpRequest("http://www.morteam.com:8080/api/login", type: "POST", data: [
            "username": "1",
            "password": "azaz"
        ]){responseText in
            self.storage.set(User(userJSON: parseJSON(responseText))._id, forKey: "_id") //TEMPORARY
            httpRequest(self.morTeamURL+"/announcements?skip="+String(self.page*20), type: "GET"){
                responseText2 in
                
            
                let newAnnouncements = parseJSON(responseText2)
                
                for(_, json):(String, JSON) in newAnnouncements {
                    self.announcements.append(Announcement(announcementJSON: json))
                }
                DispatchQueue.main.async(execute: {
                    self.announcementCollectionView.reloadData()
                })
                
                self.page += 1;
            }

        }
        
            
            
        
    }
    
    func refresh(_ sender: AnyObject){
        if (!isRefreshing){
            isRefreshing = true
            httpRequest("http://www.morteam.com:8080/api/login", type: "POST", data: [
                "username": "1",
                "password": "azaz"
            ]){responseText in
                httpRequest(self.morTeamURL+"/announcements?skip=0", type: "GET"){
                    responseText2 in
                    
                    let newAnnouncements = parseJSON(responseText2)
                    self.announcements = []
                    
                    for(_, json):(String, JSON) in newAnnouncements {
                       
                        self.announcements.append(Announcement(announcementJSON: json))
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.announcementCollectionView.reloadData()
                        self.isRefreshing = false
                        self.refreshControl.endRefreshing()
                    })
                    
                    self.page = 1
                    
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.announcements.count
    }
    
    
    @IBAction func postButtonClicked(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            let vc: PostAnnouncementVC! = self.storyboard!.instantiateViewController(withIdentifier: "PostAnnouncement") as! PostAnnouncementVC
            self.show(vc as UIViewController, sender: vc)
        })
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = announcementCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AnnouncementCell
        
        if (!isRefreshing){
            cell.layer.shouldRasterize = true;
            cell.layer.rasterizationScale = UIScreen.main.scale;
            
            let announcementAtIndex = self.announcements[(indexPath as NSIndexPath).item]
            
            cell.name.text = String(describing: announcementAtIndex.author["firstname"]) + " " + String(describing: announcementAtIndex.author["lastname"])
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "UTC")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let date = formatter.date(from: announcementAtIndex.timestamp)
            formatter.dateStyle = .long
            formatter.timeStyle = .medium
            formatter.timeZone = NSTimeZone.local
            cell.date.text = formatter.string(from: date!)
            
            let content = announcementAtIndex.content.data(using: String.Encoding.unicode, allowLossyConversion: true)
            let attrStr = try! NSMutableAttributedString(
                data: content!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
            
            attrStr.addAttribute(NSFontAttributeName,
                                 value: UIFont(
                                    name: "Exo2-Light",
                                    size: 15.0)!,
                                 range: NSRange(
                                    location: 0,
                                    length: (attrStr.length))
            )
            
            cell.content.attributedText = attrStr
            
            
            cell.profilePic.image = UIImage(named: "user")
            
            cell.backgroundColor = UIColor.white
            
            let profPicUrlString = "http://www.morteam.com:8080"+String(describing: announcementAtIndex.author["profpicpath"])+"-60"
            let profPicUrl = URL(string: profPicUrlString)
            
            if let img = imageCache[profPicUrlString] {
                cell.profilePic.image = img
            }else{
                let request: NSMutableURLRequest = NSMutableURLRequest(url: profPicUrl!)
                if let sid = storage.string(forKey: "connect.sid"){
                    request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
                }
                let mainQueue = OperationQueue.main
                NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        
                        let image = UIImage(data: data!)
                        
                        self.imageCache[profPicUrlString] = image
                        
                        DispatchQueue.main.async(execute: {
                            if let cellToUpdate = self.announcementCollectionView.cellForItem(at: indexPath) as? AnnouncementCell {
                                cellToUpdate.profilePic.image = image
                            }
                        })
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            cell.layer.shadowRadius = 2.0
            cell.layer.shadowOpacity = 0.2
            cell.layer.masksToBounds = false
            
            cell.profilePic.layer.cornerRadius = 4.2
            cell.profilePic.clipsToBounds = true
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        return CGSize(width: self.screenSize.width-10, height: 200.0)
        
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


