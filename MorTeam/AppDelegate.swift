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
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    var storage = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization ater application launch.
        GMSServices.provideAPIKey("AIzaSyASFo5RTfvh0fhVq4IakQuByt2P1mqYRKM");//Use your own API Key
        //AIzaSyASFo5RTfvh0fhVq4IakQuByt2P1mqYRKM
        UINavigationBar.appearance().barTintColor = UIColorFromHex("#FFC547")
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().isTranslucent = false
        UISearchBar.appearance().barTintColor = UIColorFromHex("#FFC547")
        UITabBar.appearance().tintColor = UIColorFromHex("#E5B13F")
        
        
        let mainVC : UIViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        
        let loginVC : UIViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        
        //let loginVC : UIViewController! = mainStoryboard.instantiateViewControllerWithIdentifier("login")
        
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FIRApp.configure()
        
        if let _ = storage.string(forKey: "connect.sid"){
            //logged in
            //if storage.bool(forKey: "noTeam") {
                //logoutSilently()
                //self.window?.rootViewController = loginVC
            //}
            //else{
                //self.window?.rootViewController = revealVC
            SocketIOManager.sharedInstance.connectSocket()
            self.window?.rootViewController = mainVC
            
            //}
        }
        else{
            //not logged in
            self.window?.rootViewController = loginVC
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.tokenRefreshNotification),name: .firInstanceIDTokenRefresh,object: nil)
        
        
        
        
            
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        SocketIOManager.sharedInstance.disconnectSocket()
        
    }
 
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            self.storage.set(refreshedToken, forKey: "deviceToken")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    // [START connect_on_active]
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    // [END connect_on_active]
    // [START disconnect_from_fcm]
    
    //func applicationDidEnterBackground(_ application: UIApplication) {
      
    // [END disconnect_from_fcm]
    
    
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let _ = storage.string(forKey: "connect.sid"){
            SocketIOManager.sharedInstance.connectSocket()
        }
        
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]

class SocketIOManager {
    
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient
    
    var connectedSockets = 0
    
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
        if (connectedSockets == 0){
            connectedSockets += 1
            self.socket.connect()
            print("connected")
        }
        
    }
    func disconnectSocket() {
        if (connectedSockets > 0){
            connectedSockets -= 1
            self.socket.disconnect()
            print("disconnected")
        }
    }
    func socketStatus() -> SocketIOClientStatus {
        return socket.status
    }
    
}


