//
//  AppDelegate.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

#if DEBUG
let ddLogLevel = DDLogLevel.Verbose;
#else
let ddLogLevel = DDLogLevel.Warning;
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TCPSessionManagerDelegate {

  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
    setupLogger()
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
    println(userInfo)
    
    if let type = userInfo["type"] as? String {
      if type == "newMessage" {
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        let alertView = UIAlertController(title: "新消息", message: "您有新消息", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: "查看", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
          println("查看")
          let navController = UINavigationController(rootViewController: JSHChatVC(chatType: ChatType.OldSession))
          navController.navigationBar.tintColor = UIColor.blackColor()
          navController.navigationBar.translucent = false
          self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
        }))
        window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
      }
    }
  }
  
  // MARK: - TCPSessionManagerDelegate
  func didOpenTCPSocket() {
//    if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
      let userID = JSHAccountManager.sharedJSHAccountManager().userid
      let userName = JSHStorage.baseInfo().name
      ZKJSTCPSessionManager.sharedInstance().clientLogin(userID, name: userName, deviceToken: deviceToken)
    
//    let notification = UILocalNotification()
//    let alertMessage = "didOpenTCPSocket"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//    }
  }
  
  func didReceivePacket(dictionary: [NSObject : AnyObject]!) {
    let type = dictionary["type"] as! NSNumber
    if type.integerValue == MessageServiceChatType.CustomerServiceTextChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceTextChatNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessageServiceChatType.CustomerServiceMediaChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceMediaChatNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessageServiceChatType.CustomerServiceImgChat.rawValue {
      NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceImgChatNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessagePaymentType.UserAccount_S2MC.rawValue {
      println("Payment is ready...")
      var orderno = ""
      if let info = dictionary["orderno"] as? String {
        orderno = info
      }
      var createdDate = ""
      if let info = dictionary["orderdate"] as? NSNumber {
        let date = NSDate(timeIntervalSince1970: info.doubleValue)
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var createdDate = dateFormatter.stringFromDate(date)
      }
      var paytotal: Float = 0.0
      if let info = dictionary["paytotal"] as? NSNumber {
        paytotal = info.floatValue
      }
      let alertMessage = "您有新账单需要支付\n订单号: \(orderno)\n创建时间: \(createdDate)\n应付金额: \(paytotal)"
      let alertView = UIAlertController(title: "账单", message: "您有新账单需要支付", preferredStyle: .Alert)
      alertView.addAction(UIAlertAction(title: "稍候支付", style: UIAlertActionStyle.Cancel, handler: nil))
      alertView.addAction(UIAlertAction(title: "立即支付", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
        let navController = UINavigationController(rootViewController: BookPayVC())
        navController.navigationBar.tintColor = UIColor.blackColor()
        navController.navigationBar.translucent = false
        self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
      }))
      window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
    } else if type.integerValue == MessagePaymentType.ShopOrderStatus_IOS.rawValue {
      println("Booking Order is ready...")
      let alertView = UIAlertController(title: "订单", message: "您的订单已确认", preferredStyle: .Alert)
      alertView.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
      window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    AlipaySDK .defaultService() .processOrderWithPaymentResult(url, standbyCallback: { ([NSObject : AnyObject]!) -> Void in
      
    })
    return true
  }
  
  // MARK: - Private Method
  func setupLogger() {
    DDLog.addLogger(DDASLLogger.sharedInstance())
    DDLog.addLogger(DDTTYLogger.sharedInstance())
    
    let logFileManager = CompressingLogFileManager(logsDirectory: LogManager.sharedInstance().logsDirectory())
    println(logFileManager.logsDirectory())
    let fileLogger = DDFileLogger(logFileManager: logFileManager)
    fileLogger.maximumFileSize = 1024 * 512
//    fileLogger.rollingFrequency = 60 * 60 * 24
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1
    DDLog.addLogger(fileLogger)
  }
  
  func setupWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
//    let naviController = UINavigationController(rootViewController: BookVC())
//    naviController.navigationBar .setBackgroundImage(UIImage(named: "星空中心"), forBarMetrics: UIBarMetrics.Default)
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
          UUID = info.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
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
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    })
  }

}

