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
 var reach: TMReachability?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HTTPSessionManagerDelegate, TCPSessionManagerDelegate {
  var loginManager: LoginManager?
  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupLogger()
    setupWindow()
    setupNotification()
    setupTCPSessionManager()
    fetchShops()
    fetchBeaconRegions()
//    setupUMSocial()//UM
    networkState()
    setupBackgroundFetch()
    setupEaseMobWithApplication(application, launchOptions: launchOptions)
    
    ZKJSHTTPSessionManager.sharedInstance().delegate = self
    
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstRun")
    
    // 因为注册的Local Notification会持久化在设备中，所以需要重置一下才能删除掉不在需要的Local Notification
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
//    // fir.im BugHD
//    FIR.handleCrashWithKey("60de6e415871c3b153cf0fabee951b58")
    
    return true
  }
  func networkState() {
    // Allocate a reachability object
    reach = TMReachability.reachabilityForInternetConnection()
    
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    reach!.reachableOnWWAN = false
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "reachabilityChanged:",
      name: kReachabilityChangedNotification,
      object: nil)
    
    reach!.startNotifier()
  }
  func reachabilityChanged(notification: NSNotification) {
    if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
      print("Service avalaible!!!")
    } else {
      print("No service avalaible!!!")
    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    print("applicationWillResignActive")
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    ZKJSTCPSessionManager.sharedInstance().deinitNetworkCommunication()
    EaseMob.sharedInstance().applicationDidEnterBackground(application)
    print("applicationDidEnterBackground")
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
    EaseMob.sharedInstance().applicationWillEnterForeground(application)
    print("applicationWillEnterForeground")
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    print("applicationDidBecomeActive")
//    UMSocialSnsService.applicationDidBecomeActive()//UM
    
//    println(window?.rootViewController)
//    if let navigationController = window?.rootViewController as? UINavigationController {
//      println(navigationController.visibleViewController)
//      if navigationController.visibleViewController is JSHChatVC {
//        let chatVC = navigationController.visibleViewController as! JSHChatVC
//        requestOfflineMessages()
//        
//        if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
//          shopMessageBadge[chatVC.shopID] = 0
//          StorageManager.sharedInstance().updateShopMessageBadge(shopMessageBadge)
//        }
//      }
//    }
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    EaseMob.sharedInstance().applicationWillTerminate(application)
    print("applicationWillTerminate")
  }
  
  // MARK: - Local Notification
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    // 测试基于经纬度的位置提醒
    let region = notification.region
    if (region != nil) {
      let alertView = UIAlertController(title: "位置提醒", message: "\(region)", preferredStyle: .Alert)
      window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
  // MARK: - Push Notification
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
    self.deviceToken = self.deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    JSHStorage.saveDeviceToken(self.deviceToken)
    print("Device Token: \(self.deviceToken)")
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print(userInfo)
    
    // 广告推送
    if let childType = userInfo["childtype"] as? NSNumber {
      if childType.integerValue == MessageUserDefineType.ClientArrivalPushAd.rawValue {
        if let aps = userInfo["aps"] as? [String: AnyObject] {
          if let alertMessage = aps["alert"] as? String {
            let alertView = UIAlertController(title: "到店通知", message: alertMessage, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .Cancel, handler: nil))
            window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
          }
        }
        // 缓存发送时间，因为iBeacon信号不稳定，避免10分钟内重复发送
        guard let shopID = userInfo["shopid"] as? String else { return }
        guard let locid = userInfo["locid"] as? String else { return }
        let regionKey = "\(shopID)-\(locid)"
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: regionKey)
        print("\(regionKey) saved at \(NSDate())")
      }
    }
  }
  
  // MARK: - Background Fetch
  func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    /*The background execution time given to an application is not infinite. iOS provides a 30 seconds time frame in order the app to be woken up, fetch new data, update its interface and then go back to sleep again. It is your duty to make sure that any performed tasks will manage to get finished within these 30 seconds, otherwise the system will suddenly stop them. If more time is required though, then the Background Transfer Service API can be used.*/
    
    let fetchStart = NSDate()
    ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print("Background Fetch: \(responseObject)")
      let shops = responseObject as! [(NSDictionary)]
      StorageManager.sharedInstance().saveShopsInfo(shops)
      completionHandler(.NewData)
      
      let fetchEnd = NSDate()
      print("Background Fetch Success Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        completionHandler(.Failed)
        let fetchEnd = NSDate()
        print("Background Fetch Fail Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
    }
  }
  
  // MARK: - TCPSessionManagerDelegate
  func didOpenTCPSocket() {
    // App在后台，只需要发一个进入区域的包
    print("didOpenTCPSocket")
    if NSUserDefaults.standardUserDefaults().boolForKey("ShouldSendEnterBeaconRegionPacket") {
      if let beaconRegion = StorageManager.sharedInstance().lastBeacon() {
        sendEnterRegionPacketWithBeacon(beaconRegion)
      }
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ShouldSendEnterBeaconRegionPacket")
    } else if NSUserDefaults.standardUserDefaults().boolForKey("ShouldSendExitBeaconRegionPacket") {
      if let beaconRegion = StorageManager.sharedInstance().lastBeacon() {
        sendExitRegionPacketWithBeacon(beaconRegion)
      }
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ShouldSendExitBeaconRegionPacket")
    }
    
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let userName = JSHStorage.baseInfo().username ?? ""
    if userID != nil {
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
    } else if type.integerValue == MessageServiceChatType.CustomerServiceTextChat_RSP.rawValue ||
              type.integerValue == MessageServiceChatType.CustomerServiceMediaChat_RSP.rawValue ||
              type.integerValue == MessageServiceChatType.CustomerServiceImgChat_RSP.rawValue ||
              type.integerValue == MessageServiceChatType.RequestWaiter_C2S_RSP.rawValue {
        NSNotificationCenter.defaultCenter().postNotificationName("MessageServiceChatCustomerServiceRSPNotification", object: self, userInfo: dictionary)
    } else if type.integerValue == MessagePaymentType.ShopOrderStatus_IOS.rawValue {
//      println("Booking Order is ready...")
//      let alertView = UIAlertController(title: "订单", message: "您的订单已确认", preferredStyle: .Alert)
//      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
//      window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
  // MARK: - HTTPSessionManagerDelegate
  func didReceiveInvalidToken() {
    window?.rootViewController = JSHHotelRegisterVC()
    ZKJSTool.showMsg("账号在别处登录，请重新重录")
  }
  
    //UM
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    let urlStr = url.absoluteString
    if urlStr.hasPrefix("SVIPPAY") {
      
    }
//    else if urlStr.hasPrefix(WXAppId) {
//        return UMSocialSnsService.handleOpenURL(url)
//    }
        return true
  }
  
  // MARK: - Private Method
  
  func setupWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    setupLoginManager()
    window?.makeKeyAndVisible()
  }
  
  func setupLoginManager() {
    loginManager = LoginManager.sharedInstance()
    loginManager?.appWindow = self.window
    loginManager?.showAnimation()
  }
  
  func setupLogger() {
    DDLog.addLogger(DDASLLogger.sharedInstance())
    DDLog.addLogger(DDTTYLogger.sharedInstance())
    
    let logFileManager = CompressingLogFileManager(logsDirectory: LogManager.sharedInstance().logsDirectory())
    print(logFileManager.logsDirectory())
    let fileLogger = DDFileLogger(logFileManager: logFileManager)
    fileLogger.maximumFileSize = 1024 * 512
//    fileLogger.rollingFrequency = 60 * 60 * 24
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1
    DDLog.addLogger(fileLogger)
  }

  func setupNotification() {
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
  
  func setupTCPSessionManager() {
    ZKJSTCPSessionManager.sharedInstance().delegate = self
    print("setupTCPSessionManager")
  }
  
  func fetchShops() {
    ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: {  (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let shops = responseObject as! [(NSDictionary)]
      StorageManager.sharedInstance().saveShopsInfo(shops)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
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
        let regionKey = "\(shopID)-\(locid)"
        beaconRegions[regionKey] = beacon
      }
      StorageManager.sharedInstance().saveBeaconRegions(beaconRegions)
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    })
  }

  //UM
  func setupUMSocial() {
//    UMSocialData.openLog(true);
//    UMSocialData.setAppKey(UMAppKey)
//    UMSocialWechatHandler.setWXAppId(WXAppId, appSecret: WXAppSecret, url: UMURL)
  }
  
  func setupBackgroundFetch() {
    UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
  }
  
  func sendEnterRegionPacketWithBeacon(beacon: [String: String]) {
    guard let shopID = beacon["shopid"] else { return }
    guard let locid = beacon["locid"] else { return }
    guard let locdesc = beacon["locdesc"] else { return }
//    guard let UUID = beacon["uuid"] else { return }
//    guard let major = beacon["major"] else { return }
//    guard let minor = beacon["minor"] else { return }
    #if DEBUG
      let appid = "SVIP_DEBUG"
      #else
      let appid = "SVIP"
    #endif
    let timestamp = Int64(NSDate().timeIntervalSince1970)
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let userName = JSHStorage.baseInfo().username ?? ""
    let deviceToken = JSHStorage.deviceToken()
    let dictionary: [String: AnyObject] = [
      "type": MessagePushType.PushLoc_IOS_A2M.rawValue,
      "devtoken": deviceToken,
      "appid": appid,
      "userid": userID,
      "shopid": shopID,
      "locid": locid,
      "locdesc": locdesc,
      "username": userName,
      "timestamp": NSNumber(longLong: timestamp)
    ]
    ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
    
//    let notification = UILocalNotification()
//    let alertMessage = "Enter \(shopID!) \(locid!) \(uuid!) \(major!) \(minor!)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  func sendExitRegionPacketWithBeacon(beacon: [String: String]) {
    let shopID = beacon["shopid"]
    let locid = beacon["locid"]
//    let uuid = beacon["uuid"]
//    let major = beacon["major"]
//    let minor = beacon["minor"]
    #if DEBUG
      let appid = "SVIP_DEBUG"
      #else
      let appid = "SVIP"
    #endif
    let timestamp = Int64(NSDate().timeIntervalSince1970)
    let dictionary: [String: AnyObject] = [
      "type": MessagePushType.PushLeaveLoc.rawValue,
      "devtoken": JSHStorage.deviceToken(),
      "appid": appid,
      "userid": JSHAccountManager.sharedJSHAccountManager().userid,
      "shopid": shopID!,
      "locid": locid!,
      "username": JSHStorage.baseInfo().username ?? "",
      "timestamp": NSNumber(longLong: timestamp)
    ]
    ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
    
//    let notification = UILocalNotification()
//    let alertMessage = "Exit \(shopID!) \(locid!) \(uuid!) \(major!) \(minor!)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  func setupEaseMobWithApplication(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
    #if DEBUG
      let cert = "SVIP_dev"
    #else
      let cert = "SVIP"
    #endif
    let appKey = "zkjs#svip"
    EaseMob.sharedInstance().registerSDKWithAppKey(appKey, apnsCertName: cert, otherConfig: [kSDKConfigEnableConsoleLogger: NSNumber(bool: false)])
    EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
}

