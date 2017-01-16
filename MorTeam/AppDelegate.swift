//
//  AppDelegate.swift
//  MorTeam
//
//  Created by arvin zadeh on 6/21/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import GoogleMaps
import SocketIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDA8cdD2qer1PFVXNsn4pGH3cgziQg_BKU");//Use your own API Key
        UINavigationBar.appearance().barTintColor = UIColorFromHex("#FFC547")
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().isTranslucent = false
        UISearchBar.appearance().barTintColor = UIColorFromHex("#FFC547")
        UITabBar.appearance().tintColor = UIColorFromHex("#E5B13F")
        
        
        let mainVC : UIViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        
        let loginVC : UIViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        
        //let loginVC : UIViewController! = mainStoryboard.instantiateViewControllerWithIdentifier("login")
        
        
        
        if let _ = storage.string(forKey: "connect.sid"){
            //logged in
            //if storage.bool(forKey: "noTeam") {
                //logoutSilently()
                //self.window?.rootViewController = loginVC
            //}
            //else{
                //self.window?.rootViewController = revealVC
            self.window?.rootViewController = mainVC
            //}
        }
        else{
            //not logged in
            self.window?.rootViewController = loginVC
        }
        
        
        
            
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

class SocketIOManager {
    
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient
    
    init() {
        
        print("socket init")
        
        if let sid = storage.string(forKey: "connect.sid") {
            
            
            let configOption = SocketIOClientOption.extraHeaders(["Cookie": "connect.sid="+sid])
            
            self.socket = SocketIOClient(socketURL: URL(string: "http://www.morteam.com")!, config: [.forcePolling(true), configOption])

            
           
        
        }else{
            //self.socket = SocketIOClient(socketURL: URL("http://www.morteam.com"))
            self.socket = SocketIOClient(socketURL: URL(string: "http://www.morteam.com")!)
        }
        
        
    }
    
    
    func connectSocket() {
        self.socket.connect()
    }
    func disconnectSocket() {
        self.socket.disconnect()
    }
    func socketStatus() -> SocketIOClientStatus {
        return socket.status
    }
    
}


