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

//UM
let UMAppKey = "55c31431e0f55a65c1002597"
let WXAppId = "wxe09e14fcb69825cc"
let WXAppSecret = "8b6355edfcedb88defa7fae31056a3f0"
let UMURL = ""
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TCPSessionManagerDelegate {
  var loginManager: LoginManager?
  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupLogger()
    setupWindow()
    setupNotification()
    setupTCPSessionManager()
    fetchBeaconRegions()
    setupUMSocial()//UM
    
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
    UMSocialSnsService.applicationDidBecomeActive()//UM
    
    println(window?.rootViewController)
    if let navigationController = window?.rootViewController as? UINavigationController {
      println(navigationController.visibleViewController)
      if navigationController.visibleViewController is JSHChatVC {
        let chatVC = navigationController.visibleViewController as! JSHChatVC
        requestOfflineMessages()
        
        if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
          shopMessageBadge[chatVC.shopID] = 0
          StorageManager.sharedInstance().updateShopMessageBadge(shopMessageBadge)
        }
      }
    }
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    println("applicationWillTerminate")
  }
  
  // MARK: - Push Notification
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
    self.deviceToken = self.deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    println("Device Token: \(self.deviceToken)")
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    println(error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    println(userInfo)
    
    if let type = userInfo["type"] as? String {
      if type == "newMessage" {
        if let shopID = userInfo["shopID"] as? String {
          let alertView = UIAlertController(title: "新消息", message: "您有新消息", preferredStyle: .Alert)
          alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
          alertView.addAction(UIAlertAction(title: "查看", style: .Default, handler: { (alertAction) -> Void in
            println("查看")
            let chatVC = JSHChatVC(chatType: .OldSession)
            chatVC.shopID = shopID
            let navController = UINavigationController(rootViewController: chatVC)
            navController.navigationBar.tintColor = UIColor.blackColor()
            navController.navigationBar.translucent = false
            self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
          }))
          window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
          
          // 存储商家消息角标
          if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
            if let badge = shopMessageBadge[shopID] {
              // 找到商家角标纪录
              shopMessageBadge[shopID] = badge + 1
              StorageManager.sharedInstance().updateShopMessageBadge(shopMessageBadge)
            } else {
              // 第一次存储商家角标纪录
              shopMessageBadge[shopID] = 1
              StorageManager.sharedInstance().updateShopMessageBadge(shopMessageBadge)
            }
          } else {
            // 第一次存储该变量
            var newShopMessageBadge = [shopID: 1]
            StorageManager.sharedInstance().updateShopMessageBadge(newShopMessageBadge)
          }
        }
      }
    }
    
    if let childType = userInfo["childType"] as? NSNumber {
      if childType.integerValue == MessageUserDefineType.Payment.rawValue {
        println("Payment is ready...")
        let content = userInfo["content"] as! String
        let data = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let dict = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as! [String: String]
        let room_type = dict["room_type"]
        let remark = dict["remark"]
        let room_rate = dict["room_rate"]
        let created = dict["created"]
        let arrival_date = dict["arrival_date"]
        let departure_date = dict["departure_date"]
        let shopid = dict["shopid"]
        let orderid = dict["orderid"]
        let reservation_no = dict["reservation_no"]
        let rooms = dict["rooms"]
        let status = dict["status"]
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.dateFromString(arrival_date!)
        let endDate = dateFormatter.dateFromString(departure_date!)
        let dayInt = NSDate.daysFromDate(startDate!, toDate: endDate!)
        
        let alertMessage = "您有新账单需要支付\n订单号: \(reservation_no!)"
        let alertView = UIAlertController(title: "账单", message: alertMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "稍候支付", style: .Cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: "查看", style: .Default, handler: { (alertAction) -> Void in
          let bookPayVC = BookPayVC()
          let order = BookOrder()
          order.shopid = shopid
          order.rooms = rooms
          order.room_type = room_type
          order.room_rate = room_rate
          order.arrival_date = arrival_date
          order.departure_date = departure_date
          order.created = created
          order.dayInt = dayInt
          order.reservation_no = reservation_no
          order.orderid = orderid
          order.status = status
          order.remark = remark
          bookPayVC.bkOrder = order
          let navController = UINavigationController(rootViewController: bookPayVC)
          navController.navigationBar.tintColor = UIColor.blackColor()
          navController.navigationBar.translucent = false
          self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
        }))
        window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
      } else if childType.integerValue == MessageUserDefineType.ShopConfirmOrder.rawValue {
        let content = userInfo["content"] as! String
        let data = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let dict = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as! [String: String]
        let reservation_no = dict["reservation_no"]
        let shop_name = dict["shop_name"]
        let arrival_date = dict["arrival_date"]
        let room_type = dict["room_type"]
        let alertView = UIAlertController(title: "订单已确定", message: "订单号:\(reservation_no!)\n您在\(shop_name!)\(arrival_date!)入住的\(room_type!)已确定", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action: UIAlertAction!) -> Void in
          UIApplication.sharedApplication().applicationIconBadgeNumber = 0
          }))
        window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
      } else if childType.integerValue == MessageUserDefineType.ShopCancelOrder.rawValue {
        let content = userInfo["content"] as! String
        let data = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let dict = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as! [String: String]
        let reservation_no = dict["reservation_no"]
        let shop_name = dict["shop_name"]
        let arrival_date = dict["arrival_date"]
        let room_type = dict["room_type"]
        let alertView = UIAlertController(title: "订单已取消", message: "订单号:\(reservation_no!)\n您在\(shop_name!)\(arrival_date!)入住的\(room_type!)已取消", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action: UIAlertAction!) -> Void in
          UIApplication.sharedApplication().applicationIconBadgeNumber = 0
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
    
    if userID != nil && userName != nil {
      ZKJSTCPSessionManager.sharedInstance().clientLogin(userID, name: userName, deviceToken: deviceToken)
    }
    
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
    } else if type.integerValue == MessageCustomType.UserDefine.rawValue {
      let childtype = dictionary["childtype"] as! NSNumber
      if childtype.integerValue == MessageUserDefineType.Payment.rawValue {
        // 
      }
    } else if type.integerValue == MessagePaymentType.ShopOrderStatus_IOS.rawValue {
//      println("Booking Order is ready...")
//      let alertView = UIAlertController(title: "订单", message: "您的订单已确认", preferredStyle: .Alert)
//      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
//      window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
    //UM
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    let urlStr = url.absoluteString
    if urlStr!.hasPrefix("SVIPPAY") {
        AlipaySDK .defaultService() .processOrderWithPaymentResult(url, standbyCallback: { ([NSObject : AnyObject]!) -> Void in
            
        })
    }else if urlStr!.hasPrefix(WXAppId) {
        return UMSocialSnsService.handleOpenURL(url)
    }
        return true
  }
  
  // MARK: - Private Method
  func requestOfflineMessages() {
    let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let dictionary: [String: AnyObject] = [
      "type": MessageServiceChatType.OfflineMssage.rawValue,
      "timestamp": NSNumber(longLong: timestamp),
      "userid": JSHAccountManager.sharedJSHAccountManager().userid
    ]
    ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
  }
  
  func setupLoginManager() {
    loginManager = LoginManager.sharedInstance()
    loginManager?.appWindow = self.window
  }
  
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
    setupLoginManager()
    loginManager?.showAnimation()
//    window?.rootViewController?.view.layer.cornerRadius = 6
//    window?.rootViewController?.view.layer.masksToBounds = true
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

  //UM
  func setupUMSocial() {
    UMSocialData.openLog(true);
    UMSocialData.setAppKey(UMAppKey)
    UMSocialWechatHandler.setWXAppId(WXAppId, appSecret: WXAppSecret, url: UMURL)
  }
}

