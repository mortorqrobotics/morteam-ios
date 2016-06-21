//
//  ViewController.swift
//  MorMap
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class ViewController: UIViewController {
    
    let morTeamURL = "http://www.morteam.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //dispatch_async(dispatch_get_main_queue()) {
        
        //Set camera
        let camera = GMSCameraPosition.cameraWithLatitude(34.06, longitude: -118.41, zoom: 5);
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera);
        mapView.myLocationEnabled = true;
        //Get locations
        httpRequest(morTeamURL+"/js/teamLocations.js", type: "GET") { responseText in
            //Parse response
            let textNoVar = responseText.substringFromIndex(responseText.startIndex.advancedBy(11))
            let noSemi = textNoVar.substringToIndex(textNoVar.endIndex.advancedBy(-2))
            let teams = self.parseJSON(noSemi)
            //Place markers
            for (team, location) in teams! {
                let lat = location["latitude"] as! Double
                let long = location["longitude"] as! Double
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(long, lat)//SWITCH THESE WHEN teamLocations.js IF FIXED
                marker.title = "Team " + team
                marker.snippet = "Team"
                marker.map = mapView
                dispatch_async(dispatch_get_main_queue(),{
                    self.view = mapView
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let storage = NSUserDefaults.standardUserDefaults()
    
    func httpRequest(url: String, type: String, cb: (responseText: String) -> Void ){
        
        let requestUrl = NSURL(string: url)
        let request = NSMutableURLRequest(URL: requestUrl!)
        request.HTTPMethod = type
        
        if let sid = storage.stringForKey("connect.sid"){
            request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print(error)
                return
            }
            
            if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [String: AnyObject]()
                    cookieProperties[NSHTTPCookieName] = cookie.name
                    cookieProperties[NSHTTPCookieValue] = cookie.value
                    cookieProperties[NSHTTPCookieDomain] = cookie.domain
                    cookieProperties[NSHTTPCookiePath] = cookie.path
                    cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                    cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                    
                    let newCookie = NSHTTPCookie(properties: cookieProperties)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
                    
                    self.storage.setObject(cookie.value, forKey: cookie.name)
                }
            }
            
            let responseText = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            cb(responseText: responseText! as String);
        }
        
        task.resume()
    }
    func parseJSON(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

}


