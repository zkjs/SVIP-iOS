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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var loginManager: LoginManager?
  var window: UIWindow?
  var deviceToken = ""

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    refreshToken()
    
    HttpService.sharedInstance.getUserinfo(nil)
    
    setupWindow()
    setupNotification()

//    setupBackgroundFetch()
    
    setupYunBa()
    setupUMStatistics()
        
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
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    print("applicationDidBecomeActive")

    
    LocationMonitor.sharedInstance.afterResume = false
    LocationMonitor.sharedInstance.stopMonitoringLocation()
    if StorageManager.sharedInstance().settingMonitoring() {
      LocationMonitor.sharedInstance.startUpdatingLocation()
    }

  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    print("applicationWillTerminate")
    LocationMonitor.sharedInstance.stopUpdatingLocation()
    LocationMonitor.sharedInstance.afterResume = false
    if StorageManager.sharedInstance().settingMonitoring() {
      LocationMonitor.sharedInstance.startMonitoringLocation()
    }
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
    print("didReceiveRemoteNotification:fetchCompletionHandler")
    print(userInfo)

    if let aps = userInfo["aps"], let msg = aps["message"] as? NSDictionary {
      if let data = msg["data"] as? NSDictionary,
          let type = msg["type"] as? String where data.count > 0 {
        // 支付通知
        if type == "PAYMENT_CONFIRM" {
          let  payInfo = PaylistmModel(dict: data)
          NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_PAYMENT, object: nil, userInfo: ["payInfo":payInfo])
        }
        // 到店欢迎,营销推送通知
        else if type == "BLE_ACTIVITY" {
          guard let title = data["title"] as? String,
            let content = data["content"] as? String else {
              return
          }
          //let alert = UIAlertView(title: title, message: content, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确认")
          //alert.show()
          
          let  payInfo = PushMessageModel(dict: data)
          NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_WELCOME, object: nil, userInfo: ["welcomeInfo":payInfo])
        }
        // change logo
        else if type == "ANOTHER_SHOP" {
          let  shopLogo = ShopLogoModel(dic: data)
          StorageManager.sharedInstance().saveShopLogoToCache(shopLogo)
          NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_CHANGELOGO, object: nil, userInfo: ["logoInfo":shopLogo])
        }
      }
    }
    completionHandler(.NewData)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print("didReceiveRemoteNotification")
    print(userInfo)
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
  
  // MARK: - HTTPSessionManagerDelegate
  
  func didReceiveInvalidToken() {
    // 清理系统缓存
    AccountManager.sharedInstance().clearAccountCache()
    
    // 弹出登录框
    let nc = BaseNC(rootViewController: LoginFirstVC())
    window?.rootViewController?.presentViewController(nc, animated: true, completion: nil)
    ZKJSTool.showMsg("账号在别处登录，请重新重录")
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onMessageReceived:", name: kYBDidReceiveMessageNotification, object: nil)
  }
  
  func unregisterRemoteNotification() {
    UIApplication.sharedApplication().unregisterForRemoteNotifications()
  }
  
  func setupUMStatistics() {
    let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    MobClick.setAppVersion(version)
    MobClick.startWithAppkey(ZKJSConfig.sharedInstance.UMAppKey, reportPolicy: BATCH, channelId: nil)
  }
  
  //send all beacon logs to server 10 seconds later
  func sendErrorsToServerLater() {
    delay(seconds: 20 ){BeaconErrors.uploadLogs()}
  }
  
  func didLogout() {
    // 清理系统缓存
    AccountManager.sharedInstance().clearAccountCache()
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    
    let window =  UIApplication.sharedApplication().keyWindow
    window?.rootViewController = BaseNC(rootViewController: LoginFirstVC())
    ZKJSTool.showMsg("登录过期，请重新重录")
  }
  
  func onMessageReceived(notification: NSNotification) {
    if let message = notification.object as? YBMessage {
      if let payloadString = NSString(data:message.data, encoding:NSUTF8StringEncoding) as? String {
        print("[Message] \(message.topic) -> \(payloadString)")
      }
    }
  }
  
}

