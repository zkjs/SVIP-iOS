////
//  AppDelegate.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

//#if DEBUG
//let ddLogLevel = DDLogLevel.Verbose;
//#else
//let ddLogLevel = DDLogLevel.Warning;
//#endif

// 友盟
let UMAppKey = "55c31431e0f55a65c1002597"
let UMURL = ""
// 微信
let WXAppId = "wxe09e14fcb69825cc"
let WXAppSecret = "8b6355edfcedb88defa7fae31056a3f0"
// 高德
let AMapKey = "7945ba33067bb07845e8a60d12135885"
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
//    setupUMSocial()//UM
    networkState()
//    setupBackgroundFetch()
    setupYunBa()
    setupAMap()
    setupUMStatistics()
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
    print("applicationDidEnterBackground")
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
    EaseMob.sharedInstance().application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
    self.deviceToken = self.deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    print("Device Token: \(self.deviceToken)")
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    EaseMob.sharedInstance().application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    print(error)
  }
  
//  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//    print(userInfo)
//  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    print(userInfo)
//    let localNotification:UILocalNotification = UILocalNotification()
//    localNotification.alertAction = "Testing notifications on iOS8"
//    localNotification.alertBody = "Woww it works!!"
//    localNotification.fireDate = NSDate(timeIntervalSinceNow: 3)
//    localNotification.category = "INVITE_CATEGORY";
//    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//    completionHandler(.NewData)
  }
  
  // MARK: - Background Fetch
  
  func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    /*The background execution time given to an application is not infinite. iOS provides a 30 seconds time frame in order the app to be woken up, fetch new data, update its interface and then go back to sleep again. It is your duty to make sure that any performed tasks will manage to get finished within these 30 seconds, otherwise the system will suddenly stop them. If more time is required though, then the Background Transfer Service API can be used.*/
    
    
    let fetchStart = NSDate()
    ZKJSJavaHTTPSessionManager.sharedInstance().getHomeImageWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      print("Background Fetch: \(responseObject)")
      if let array = responseObject as? NSArray {
        var urlArray = [String]()
        for dic in array {
          if let url = dic["url"] as? String {
            urlArray.append(url)
          }
        }
        StorageManager.sharedInstance().saveHomeImages(urlArray)
        completionHandler(.NewData)
        
        let fetchEnd = NSDate()
        print("Background Fetch Success Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
      } else {
        completionHandler(.Failed)
        let fetchEnd = NSDate()
        print("Background Fetch Fail Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        completionHandler(.Failed)
        let fetchEnd = NSDate()
        print("Background Fetch Fail Duration: \(fetchEnd.timeIntervalSinceDate(fetchStart))")
    }
  }
  
  // MARK: - HTTPSessionManagerDelegate
  
  func didReceiveInvalidToken() {
    // 清理系统缓存
    AccountManager.sharedInstance().clearAccountCache()
    
    // 登出环信
    EaseMob.sharedInstance().chatManager.removeAllConversationsWithDeleteMessages!(true, append2Chat: true)
    let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
    print("登出前环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    EaseMob.sharedInstance().chatManager.logoffWithUnbindDeviceToken(true, error: error)
    print("登出后环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    if error != nil {
      print(error.debugDescription)
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
    }
    
    // 弹出登录框
    let nc = BaseNC(rootViewController: LoginVC())
    window?.rootViewController?.presentViewController(nc, animated: true, completion: nil)
    ZKJSTool.showMsg("账号在别处登录，请重新重录")
  }
  
  //UM
  //iOS 8 及以下
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    let canHandleURL = Pingpp.handleOpenURL(url, withCompletion: nil) 
    let urlStr = url.absoluteString
    if urlStr.hasPrefix("SVIPPAY") {
    }
    return canHandleURL
  }
  //iOS 9 及以上

  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
     let canHandleURL = Pingpp.handleOpenURL(url, withCompletion: nil)
      return canHandleURL
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
//    DDLog.addLogger(DDASLLogger.sharedInstance())
//    DDLog.addLogger(DDTTYLogger.sharedInstance())
//    
//    let logFileManager = CompressingLogFileManager(logsDirectory: LogManager.sharedInstance().logsDirectory())
//    print(logFileManager.logsDirectory())
//    let fileLogger = DDFileLogger(logFileManager: logFileManager)
//    fileLogger.maximumFileSize = 1024 * 512
////    fileLogger.rollingFrequency = 60 * 60 * 24
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 1
//    DDLog.addLogger(fileLogger)
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
  
  func setupAMap() {
    AMapNaviServices.sharedServices().apiKey = AMapKey
    AMapLocationServices.sharedServices().apiKey = AMapKey
  }
  
  func setupUMStatistics() {
    let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    MobClick.setAppVersion(version)
    MobClick.startWithAppkey(UMAppKey, reportPolicy: BATCH, channelId: nil)
  }
  
}

