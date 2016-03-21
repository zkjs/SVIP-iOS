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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var loginManager: LoginManager?
  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    HttpService.sharedInstance.getUserinfo(nil)
    
    setupWindow()
    setupNotification()

//    setupBackgroundFetch()
    
    setupYunBa()
    setupUMStatistics()
    refreshToken()
    //ZKJSHTTPSessionManager.sharedInstance().delegate = self
        
    // 因为注册的Local Notification会持久化在设备中，所以需要重置一下才能删除掉不在需要的Local Notification
    UIApplication.sharedApplication().cancelAllLocalNotifications()
   
    // 监控Token是否过期
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLogout", name: KNOTIFICATION_LOGOUTCHANGE, object: nil)
    
    // app was launched when significant location changed
    if let _ = launchOptions?[UIApplicationLaunchOptionsLocationKey] {
      LocationMonitor.sharedInstance.afterResume = true
      LocationMonitor.sharedInstance.startMonitoringLocation()
    }
    
    //send error logs to server
    sendErrorsToServerLater()

    return true
  }
  
  func refreshToken() {
    HttpService.sharedInstance.managerToken { (json, error) -> () in
      
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
    print("applicationDidEnterBackground")
    // 根据测试情况调整，Backgournd 模式下选择 startMonitoringSignificantLocationChanges 还是 startUpdatingLocation ?
    // startMonitoringSignificantLocationChanges 省电但是频率慢，精度低
    // startUpdatingLocation 精度高，上传频率有保证，但是耗电
    /*LocationMonitor.sharedInstance.stopUpdatingLocation()
    LocationMonitor.sharedInstance.afterResume = false
    LocationMonitor.sharedInstance.startMonitoringLocation() */
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    print("applicationWillEnterForeground")
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    print("applicationDidBecomeActive")

    
    LocationMonitor.sharedInstance.afterResume = false
    LocationMonitor.sharedInstance.stopMonitoringLocation()
    LocationMonitor.sharedInstance.startUpdatingLocation()

  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    print("applicationWillTerminate")
    LocationMonitor.sharedInstance.stopUpdatingLocation()
    LocationMonitor.sharedInstance.afterResume = false
    LocationMonitor.sharedInstance.startMonitoringLocation()
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
    
    // 将DeviceToken 存储在YunBa的云端，那么可以通过YunBa发送APNs通知
    YunBaService.storeDeviceToken(deviceToken) { (success, error) -> Void in
      if success {
        print("store device token to YunBa success")
      } else {
        print("store device token to YunBa failed due to: \(error)")
      }
    }
    
    self.deviceToken = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
    self.deviceToken = self.deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    print("Device Token: \(self.deviceToken)")
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
  }

  
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
    
    HttpService.sharedInstance.getHomePictures { (imgs, error) -> Void in
      if let imgs = imgs {
        if imgs.count > 0 {
          completionHandler(.NewData)
        } else {
          completionHandler(.NoData)
        }
      } else {
        completionHandler(.Failed)
      }
    }
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
  

  func setupNotification() {
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
  
  
  func setupYunBa() {
    YunBaService.setupWithAppkey(ZKJSConfig.sharedInstance.YunBaAppKey)
  }
  
  func unregisterRemoteNotification() {
    UIApplication.sharedApplication().unregisterForRemoteNotifications()
  }
  
  func setupUMStatistics() {
    let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    MobClick.setAppVersion(version)
    MobClick.startWithAppkey(UMAppKey, reportPolicy: BATCH, channelId: nil)
  }
  
  //send all beacon logs to server 10 seconds later
  func sendErrorsToServerLater() {
    delay(seconds: 20 ){BeaconErrors.uploadLogs()}
  }
  
  func didLogout() {
    // 清理系统缓存
    AccountManager.sharedInstance().clearAccountCache()
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    
    // 弹出登录框
    let window =  UIApplication.sharedApplication().keyWindow
    window?.rootViewController = BaseNC(rootViewController: LoginVC())
    ZKJSTool.showMsg("登录过期，请重新重录")
  }
}

