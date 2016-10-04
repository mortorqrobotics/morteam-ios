//
//  Util.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

// Most of this is the Util.swift from MorScout

import Foundation
import UIKit

let storage = UserDefaults.standard

func parseJSON(_ string: String) -> JSON {
    let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
    return JSON(data: data!)
}
func parseJSONMap(_ text: String) -> [String:AnyObject]? {
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}

func getUserOtherThanSelf(_ userMembers: JSON) -> User {
    if let _id = storage.string(forKey: "_id") {
        if(String(describing: userMembers[0]["_id"]) == _id){
            return User(userJSON: userMembers[1])
        }else{
            return User(userJSON: userMembers[0])
        }
    }
    return User(userJSON: userMembers[1])
}


func UIColorFromHex( _ hexOld: String) -> UIColor {
    
    var hex = String();
    if hexOld.hasPrefix("#") {
        hex = hexOld.substring(with: (hexOld.characters.index(hexOld.startIndex, offsetBy: 1) ..< hexOld.endIndex))
    }
    
    //get each color
    let r = hex.substring(with: (hex.startIndex ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
    let g = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
    let b = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
    
    //convert to decimal
    let rd = UInt8(strtoul(r, nil, 16))
    let gd = UInt8(strtoul(g, nil, 16))
    let bd = UInt8(strtoul(b, nil, 16))
    
    //convert to floats from UInt8
    let rdFloat = CGFloat(rd)
    let gdFloat = CGFloat(gd)
    let bdFloat = CGFloat(bd)
    
    return UIColor(red: rdFloat/255, green: gdFloat/255, blue: bdFloat/255, alpha: 1)
}

func UIColorFromHex( _ hexGiven: String, alpha: Double) -> UIColor {
    var hex = String();
    if hexGiven.hasPrefix("#") {
        hex = hexGiven.substring(with: (hexGiven.characters.index(hexGiven.startIndex, offsetBy: 1) ..< hexGiven.endIndex))
    }
    
    //get each color
    let r = hex.substring(with: (hex.startIndex ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
    let g = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
    let b = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
    
    //convert to decimal
    let rd = UInt8(strtoul(r, nil, 16))
    let gd = UInt8(strtoul(g, nil, 16))
    let bd = UInt8(strtoul(b, nil, 16))
    
    //convert to floats from UInt8
    let rdFloat = CGFloat(rd)
    let gdFloat = CGFloat(gd)
    let bdFloat = CGFloat(bd)
    
    return UIColor(red: rdFloat/255, green: gdFloat/255, blue: bdFloat/255, alpha: CGFloat(alpha))
}

func httpRequest(_ url: String, type: String, data: [String: Any], cb: @escaping (_ responseText: String) -> Void ){
    
    let requestUrl = URL(string: url)
    let request = NSMutableURLRequest(url: requestUrl!)
    request.httpMethod = type
//    var postData = ""
//    for(key, value) in data{
//        postData += key + "=" + value + "&"
//    }
//    postData = String(postData.characters.dropLast())
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
    }
    catch{
        
    }
    //request.httpBody = try JSONSerialization.data(withJSONObject: data, options: []) //postData.data(using: String.Encoding.utf8)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //x-www-form-urlencoded
    if let sid = storage.string(forKey: "connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
        data, response, error in
        
        if error != nil {
            print(error)
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey: AnyObject]()
                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int) as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000) as AnyObject?
                
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
                
                storage.set(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
        cb(responseText! as String);
    }) 
    
    task.resume()
}

func httpRequest(_ url: String, type: String, cb: @escaping (_ responseText: String) -> Void ){
    
    let requestUrl = URL(string: url)
    let request = NSMutableURLRequest(url: requestUrl!)
    request.httpMethod = type
    
    if let sid = storage.string(forKey: "connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
        data, response, error in
        
        if error != nil {
            print(error)
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey
                    : AnyObject]()
                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int) as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000) as AnyObject?
                
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
                
                storage.set(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
        cb(responseText! as String);
    }) 
    
    task.resume()
}
