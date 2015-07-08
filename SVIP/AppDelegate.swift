//
//  AppDelegate.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TCPSessionManagerDelegate {

  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupWindow()
    setupNotification()
    setupTCPSessionManager()
    fetchBeaconRegions()
    
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    println("applicationWillResignActive")
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    ZKJSTCPSessionManager.sharedInstance().deinitNetworkCommunication()
    println("applicationDidEnterBackground")
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
    println("applicationWillEnterForeground")
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    println("applicationDidBecomeActive")
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    println("applicationWillTerminate")
  }
  
  // MARK: - Push Notification
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
    self.deviceToken = self.deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    println(self.deviceToken)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    println(error.localizedDescription)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//    let aps = userInfo["aps"] as! NSDictionary
//    let alertMessage = aps["alert"] as! String
//    let alert = UIAlertView(title: "新消息通知", message: alertMessage, delegate: nil, cancelButtonTitle: "了解")
//    alert.show()
    println(userInfo)
  }
  
  // MARK: - TCPSessionManagerDelegate
  func didOpenTCPSocket() {
    if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
      let userID = JSHAccountManager.sharedJSHAccountManager().userid
      let userName = JSHStorage.baseInfo().name
      ZKJSTCPSessionManager.sharedInstance().clientLogin(userID, name: userName, deviceToken: deviceToken)
    }
  }
  
  func didReceivePacket(dictionary: [NSObject : AnyObject]!) {
    let type = dictionary["type"] as! NSNumber
    if type.integerValue == MessageServiceChatType.CustomerServiceTextChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceTextChatNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessageServiceChatType.CustomerServiceMediaChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceMediaChatNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessageServiceChatType.CustomerServiceImgChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceImgChatNotification", object: self, userInfo: dictionary)
    }
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    AlipaySDK .defaultService() .processOrderWithPaymentResult(url, standbyCallback: { ([NSObject : AnyObject]!) -> Void in
      
    })
    return true
  }
  
  // MARK: - Private Method
  func setupWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let naviController = UINavigationController(rootViewController: BookVC())
    naviController.navigationBar .setBackgroundImage(UIImage(named: "星空中心"), forBarMetrics: UIBarMetrics.Default)
//    window?.rootViewController = naviController
    window?.rootViewController = JSHAnimationVC()
    window?.rootViewController?.view.layer.cornerRadius = 6
    window?.rootViewController?.view.layer.masksToBounds = true
    window?.makeKeyAndVisible()
  }

  func setupNotification() {
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
  
  func setupTCPSessionManager() {
    ZKJSTCPSessionManager.sharedInstance().delegate = self
    println("setupTCPSessionManager")
  }
  
  func fetchBeaconRegions() {
    ZKJSHTTPSessionManager.sharedInstance().getBeaconRegionListWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      var beaconRegions = [String: [String: String]]()
      
      for beaconInfo in responseObject as! NSArray {
        var shopID = ""
        var UUID = ""
        var major = ""
        var minor = ""
        var locid = ""
        var locdesc = ""
        if let info = beaconInfo["shopid"] as? String {
          shopID = info
        }
        if let info = beaconInfo["uuid"] as? String {
          UUID = info
        }
        if let info = beaconInfo["major"] as? String {
          major = info
        }
        if let info = beaconInfo["minior"] as? String {
          minor = info
        }
        if let info = beaconInfo["locid"] as? String {
          locid = info
        }
        if let info = beaconInfo["locdesc"] as? String {
          locdesc = info
        }
        let beacon = [
          "shopid": shopID,
          "uuid": UUID,
          "major": major,
          "minor": minor,
          "locid": locid,
          "locdesc": locdesc
        ]
        let key = "\(shopID)\(UUID)\(major)\(minor)\(locid)"
        beaconRegions[key] = beacon
      }
      StorageManager.sharedInstance().saveBeaconRegions(beaconRegions)
      NSNotificationCenter.defaultCenter().postNotificationName("ZKJSSetupBeaconRegions", object: nil)
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    })
  }

}

