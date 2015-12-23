////
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
//var reach: TMReachability?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HTTPSessionManagerDelegate {
  
  var loginManager: LoginManager?
  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    setupWindow()
    setupNotification()
//    fetchShops()
    fetchBeaconRegions()
//    setupUMSocial()//UM
    networkState()
//    setupBackgroundFetch()
    setupYunBa()
    setupEaseMobWithApplication(application, launchOptions: launchOptions)
    
    ZKJSHTTPSessionManager.sharedInstance().delegate = self
        
    // 因为注册的Local Notification会持久化在设备中，所以需要重置一下才能删除掉不在需要的Local Notification
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
//    // fir.im BugHD
//    FIR.handleCrashWithKey("60de6e415871c3b153cf0fabee951b58")
    
    return true
  }
  func networkState() {
//    // Allocate a reachability object
//    reach = TMReachability.reachabilityForInternetConnection()
//    
//    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
//    reach!.reachableOnWWAN = false
//    
//    // Here we set up a NSNotification observer. The Reachability that caused the notification
//    // is passed in the object parameter
//    NSNotificationCenter.defaultCenter().addObserver(self,
//      selector: "reachabilityChanged:",
//      name: kReachabilityChangedNotification,
//      object: nil)
//    
//    reach!.startNotifier()
  }
  
  func reachabilityChanged(notification: NSNotification) {
//    if reach!.isReachableViaWiFi() || reach!.isReachableViaWWAN() {
//      print("Service avalaible!!!")
//    } else {
//      print("No service avalaible!!!")
//    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    print("applicationWillResignActive")
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    EaseMob.sharedInstance().applicationDidEnterBackground(application)
    print("applicationDidEnterBackground")
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
    print("Device Token: \(self.deviceToken)")
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print(userInfo)
    // 广告推送
  }
  
//  // MARK: - Background Fetch
//  
//  func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//    /*The background execution time given to an application is not infinite. iOS provides a 30 seconds time frame in order the app to be woken up, fetch new data, update its interface and then go back to sleep again. It is your duty to make sure that any performed tasks will manage to get finished within these 30 seconds, otherwise the system will suddenly stop them. If more time is required though, then the Background Transfer Service API can be used.*/
//    
//    if AccountManager.sharedInstance().isLogin() == false {
//      completionHandler(.Failed)
//      return
//    }
//    
//    let fetchStart = NSDate()
//    ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//      print("Background Fetch: \(responseObject)")
//      let shops = responseObject as! [(NSDictionary)]
//      StorageManager.sharedInstance().saveShopsInfo(shops)
//      completionHandler(.NewData)
//      
//      let fetchEnd = NSDate()
//      print("Background Fetch Success Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        completionHandler(.Failed)
//        let fetchEnd = NSDate()
//        print("Background Fetch Fail Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
//    }
//  }
  
  // MARK: - HTTPSessionManagerDelegate
  
  func didReceiveInvalidToken() {
    window?.rootViewController?.presentViewController(LoginVC(), animated: true, completion: nil)
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
    loginManager?.appWindow = window
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
  
//  func fetchShops() {
//    ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: {  (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//      let shops = responseObject as! [(NSDictionary)]
//      StorageManager.sharedInstance().saveShopsInfo(shops)
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        
//    }
//  }
  
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
  
//  func setupBackgroundFetch() {
//    UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
//  }
  
  func setupEaseMobWithApplication(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
    #if DEBUG
      let cert = "SVIP_dev"
    #else
      let cert = "SVIP"
    #endif
    let appKey = "zkjs#svip"
    
    EaseSDKHelper.shareHelper().easemobApplication(application,
      didFinishLaunchingWithOptions: launchOptions,
      appkey: appKey,
      apnsCertName: cert,
      otherConfig: [kSDKConfigEnableConsoleLogger: NSNumber(bool: false)])
  }
  
  func setupYunBa() {
    let appKey = "566563014407a3cd028aa72f"
    YunBaService.setupWithAppkey(appKey)
  }
  
}

