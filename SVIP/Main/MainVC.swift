//
//  MainVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation

class MainVC: UIViewController, UINavigationControllerDelegate, CRMotionViewDelegate, CLLocationManagerDelegate, AMapSearchDelegate {
  
  @IBOutlet weak var settingsButton: UIButton!
  
  @IBOutlet weak var mainButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: MIBadgeButton!

  @IBOutlet weak var statusLabel: UIButton!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var tipsLabel: UIButton!
  
  @IBOutlet weak var regionLabel: UILabel!
  @IBOutlet weak var checkinLabel: UIButton!
  @IBOutlet weak var checkinSubLabel: UILabel!
  
  let locationManager = CLLocationManager()
  
  var beaconRegions = [String: [String: String]]()
  var locationSearch = AMapSearchAPI()
  
  // MARK: - View Lifecycle
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    locationManager.startMonitoringVisits()
    setupNotification()
    setupCoreLocationService()
    setupMotionView()
    setupRightButton()
    setupBeaconMonitor()
    initTCPSessionManager()
    initSmartPanelUI()
    
    // 测试基于经纬度的位置提醒
    let localNotification = UILocalNotification()
    localNotification.alertBody = "欢迎来到中科院先进所.."
    localNotification.regionTriggersOnce = false
    let coordinate = CLLocationCoordinate2D(latitude: 22.599119, longitude: 113.985428)
    localNotification.region = CLCircularRegion(center: coordinate, radius: 1000, identifier: "Test_Location_Notification")
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: true)//为了保证每次进入首页无navigationbar页面效果
    navigationController?.delegate = self
    
    //daifengyi
    //应用于已注册用户在新客户端登陆情况
    if let image = JSHStorage.baseInfo().avatarImage {
      settingsButton.setImage(JSHStorage.baseInfo().avatarImage, forState: .Normal)
    }else {
      let userid = JSHStorage.baseInfo().userid
      let urlStr = kBaseURL.stringByAppendingPathComponent("uploads/users/\(userid).jpg")
      let url = NSURL(string: urlStr)
      settingsButton .sd_setImageWithURL(url, forState: UIControlState.Normal, placeholderImage: nil, options: SDWebImageOptions.RetryFailed | SDWebImageOptions.LowPriority)
    }
    
    setupLeftRightButtons()
    updateSmartPanel()
    updateMessageBadge()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)//必须为false，否则进栈视图无navigationbar
    navigationController?.delegate = nil
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  // MARK: - CRMotionView Delegate
  func scrollViewDidScrollToOffset(offset: CGPoint) {
    println(offset)
  }
  
  // MARK: - Private Method
  func initSmartPanelUI() {
    statusLabel.hidden = true
    infoLabel.hidden = true
    //    tipsLabel.hidden = true
    regionLabel.hidden = true
    checkinLabel.hidden = true
    checkinSubLabel.hidden = true
  }
  
  func initTCPSessionManager() {
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
  }
  
  func setupNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSmartPanel", name: "UIApplicationDidBecomeActiveNotification", object: nil)
  }
  
  func setupLeftRightButtons() {
    if NSUserDefaults.standardUserDefaults().boolForKey("isFirstRun") {
      leftButton.hidden = false
      rightButton.hidden = false
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstRun")
    } else {
      leftButton.hidden = true
      rightButton.hidden = true
    }
  }
  
  func setupRightButton() {
    rightButton.badgeEdgeInsets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 3.0)
    rightButton.badgeBackgroundColor = UIColor.redColor()
    rightButton.badgeString = nil
  }
  
  func setupMotionView() {
    let motionView = YXTMotionView(frame: UIScreen.mainScreen().bounds, image: UIImage(named: "星空中心"))
    println("Bounds: \(UIScreen.mainScreen().bounds)")
    motionView.delegate = self
    motionView.motionEnabled = true
    motionView.scrollIndicatorEnabled = false
    motionView.zoomEnabled = false
    motionView.scrollDragEnabled = false
    motionView.scrollBounceEnabled = false
    view.addSubview(motionView)
    view.sendSubviewToBack(motionView)
  }
  
  func setupCoreLocationService() {
    if CLLocationManager.authorizationStatus() == .Denied {
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    } else if CLLocationManager.authorizationStatus() == .Restricted {
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    }
    
    locationManager.delegate = self
    if CLLocationManager.authorizationStatus() == .NotDetermined {
      locationManager.requestAlwaysAuthorization()
      return
    }
    
    setupBeaconMonitor()
    setupGPSMonitor()
    println("setupCoreLocationService")
  }
  
  func setupBeaconMonitor() {
    beaconRegions = StorageManager.sharedInstance().beaconRegions()
    
    for key in beaconRegions.keys {
      if let beaconInfo = beaconRegions[key] {
        let shopID = beaconInfo["shopid"]
        let uuid = beaconInfo["uuid"]
        let majorString = beaconInfo["major"]
        let minorString = beaconInfo["minor"]
        let identifier = key
        var major = 0
        var minor = 0
        if let majorValue = majorString?.toInt() {
          major = majorValue
        }
        if let minorValue = minorString?.toInt() {
          minor = minorValue
        }
        if minor == 0 && major == 0 {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          beaconRegion.notifyEntryStateOnDisplay = true
          locationManager.startMonitoringForRegion(beaconRegion)
        } else if minor == 0 {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          beaconRegion.notifyEntryStateOnDisplay = true
          locationManager.startMonitoringForRegion(beaconRegion)
        } else {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          beaconRegion.notifyEntryStateOnDisplay = true
          locationManager.startMonitoringForRegion(beaconRegion)
        }
      }
    }
  }
  
  func setupGPSMonitor() {
//    locationManager.startMonitoringVisits()
    locationManager.startMonitoringSignificantLocationChanges()
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    locationManager.startUpdatingLocation()
//    locationSearch = AMapSearchAPI(searchKey: "7945ba33067bb07845e8a60d12135885", delegate: self)
  }
  
  func determineCurrentRegionState() {
    if let beaconInfo = StorageManager.sharedInstance().lastBeacon() {
      let uuid = beaconInfo["uuid"]
      let majorString = beaconInfo["major"]
      let minorString = beaconInfo["minor"]
      let identifier = "DetermineCurrentRegionState"
      var major = 0
      var minor = 0
      if let majorValue = majorString?.toInt() {
        major = majorValue
      }
      if let minorValue = minorString?.toInt() {
        minor = minorValue
      }
      if minor == 0 && major == 0 {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      } else if minor == 0 {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      } else {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      }
    }
    updateSmartPanelUI()
  }
  
  func didEnterBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    if let beaconRegion = beaconRegions[region.identifier] {
      let shopID = beaconRegion["shopid"]
      let locid = beaconRegion["locid"]
      let uuid = beaconRegion["uuid"]
      let major = beaconRegion["major"]
      let minor = beaconRegion["minor"]
      if NSUserDefaults.standardUserDefaults().boolForKey("DidLoginTCPSocket") {
        #if DEBUG
          let appid = "HOTELVIP_DEBUG"
        #else
          let appid = "HOTELVIP"
        #endif
        let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        let dictionary: [String: AnyObject] = [
          "type": MessagePushType.PushLoc_IOS_A2M.rawValue,
          "devtoken": JSHStorage.deviceToken(),
          "appid": appid,
          "userid": JSHAccountManager.sharedJSHAccountManager().userid,
          "shopid": shopID!,
          "locid": locid!,
          "username": JSHStorage.baseInfo().username ?? "",
          "timestamp": NSNumber(longLong: timestamp)
        ]
        ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
        StorageManager.sharedInstance().updateLastBeacon(beaconRegion)
      } else {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ShouldSendEnterBeaconRegionPacket")
        ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
      }
    }
  }
  
  func didExitBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    if let beaconRegion = beaconRegions[region.identifier] {
      let shopID = beaconRegion["shopid"]
      let locid = beaconRegion["locid"]
      let uuid = beaconRegion["uuid"]
      let major = beaconRegion["major"]
      let minor = beaconRegion["minor"]
      if NSUserDefaults.standardUserDefaults().boolForKey("DidLoginTCPSocket") {
        #if DEBUG
          let appid = "HOTELVIP_DEBUG"
        #else
          let appid = "HOTELVIP"
        #endif
        let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
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
        StorageManager.sharedInstance().updateLastBeacon(nil)
      } else {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ShouldSendExitBeaconRegionPacket")
        ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
      }
    }
  }
  
  func updateMessageBadge() {
    if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
      var totalBadge = 0
      for shopID in shopMessageBadge.keys {
        totalBadge += shopMessageBadge[shopID]!
      }
      if totalBadge == 0 {
        rightButton.badgeString = nil
      } else {
        rightButton.badgeString = String(totalBadge)
      }
    } else {
      rightButton.badgeString = nil
    }
  }
  
  func updateSmartPanel() {
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    ZKJSHTTPSessionManager.sharedInstance().getLatestOrderWithUserID(userID, token: token, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let orderArray = responseObject as! NSArray
      if orderArray.count > 0 {
        let lastOrder = orderArray.firstObject as! NSDictionary
        let order = BookOrder()
        order.arrival_date = lastOrder["arrival_date"] as? String
        order.created = lastOrder["created"] as? String
        order.departure_date = lastOrder["departure_date"] as? String
        order.guest = lastOrder["guest"] as? String
        order.guesttel = lastOrder["guesttel"] as? String
        order.orderid = lastOrder["id"] as? String
        order.remark = lastOrder["remark"] as? String
        order.reservation_no = lastOrder["reservation_no"] as? String
        order.room_rate = lastOrder["room_rate"] as? String
        order.room_type = lastOrder["room_type"] as? String
        order.room_typeid = lastOrder["room_typeid"] as? String
        order.rooms = lastOrder["rooms"] as? String
        order.shopid = lastOrder["shopid"] as? String
        order.fullname = lastOrder["fullname"] as? String
        order.status = lastOrder["status"] as? String
        order.nologin = lastOrder["nologin"] as? String
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.dateFromString(order.arrival_date)
        let endDate = dateFormatter.dateFromString(order.departure_date)
        order.dayInt = NSDate.daysFromDate(startDate!, toDate: endDate!)
        StorageManager.sharedInstance().updateLastOrder(order)
      }
      self.determineCurrentRegionState()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func postGPSLocation(coordinate: CLLocationCoordinate2D) {
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let traceTime = dateFormatter.stringFromDate(NSDate())
    ZKJSHTTPSessionManager.sharedInstance().postGPSWithUserID(userID, token: token, longitude: "\(coordinate.longitude)", latitude: "\(coordinate.latitude)", traceTime: traceTime, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
//    let notification = UILocalNotification()
//    let alertMessage = "\(coordinate.latitude), \(coordinate.longitude), \(traceTime)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  func updateSmartPanelUI() {
    statusLabel.hidden = false
    infoLabel.hidden = false
//    tipsLabel.hidden = false
    regionLabel.hidden = false
    checkinLabel.hidden = false
//    checkinSubLabel.hidden = false
    
    let beacon = StorageManager.sharedInstance().lastBeacon()
    println("Last Beacon: \(beacon)")
    let order = StorageManager.sharedInstance().lastOrder()
    println("Last Order: \(order)")
    
    if beacon != nil {
      regionLabel.text = beacon!["locdesc"]
    } else {
      regionLabel.text = "不在酒店"
    }
    
    if order?.nologin.toInt() == 0 {
      checkinLabel.setTitle(" 免前台服务已经推出", forState: .Normal)
      checkinSubLabel.text = "立即了解"
    } else {
      checkinLabel.setTitle(" 您具有申请免前台的特权", forState: .Normal)
      checkinSubLabel.text = "立即查看"
    }
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    infoLabel.hidden = true
    switch ruleType {
    case .InRegion_HasOrder_Checkin:
      var startDateString = order?.arrival_date
      var endDateString = order?.departure_date
      var dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.dateFromString(startDateString!)
      let endDate = dateFormatter.dateFromString(endDateString!)
      let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
      dateFormatter.dateFormat = "M/dd"
      startDateString = dateFormatter.stringFromDate(startDate!)
      if NSDate.daysFromDate(NSDate(), toDate: endDate!) == 0 {
        // 退房状态
        statusLabel.setTitle(" 您的订单今天需要退房，旅途愉快", forState: .Normal)
        statusLabel.setImage(UIImage(named: "sl_tuifang"), forState: .Normal)
      } else {
        // 入住状态
        if let location = beacon!["locdesc"] {
          if location.isEmpty {
            statusLabel.setTitle(" 您已入住\((order?.fullname)!)，旅途愉快", forState: .Normal)
          } else {
            statusLabel.setTitle(" 您已到达\(location)，旅途愉快", forState: .Normal)
          }
        }
        statusLabel.setImage(UIImage(named: "sl_ruzhu"), forState: .Normal)
      }
      
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 点击智键快速聊天，长按智键呼叫服务员", forState: .Normal)
    case .InRegion_HasOrder_UnCheckin:
      var startDateString = order?.arrival_date
      var endDateString = order?.departure_date
      var dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.dateFromString(startDateString!)
      let endDate = dateFormatter.dateFromString(endDateString!)
      let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
      dateFormatter.dateFormat = "M/dd"
      startDateString = dateFormatter.stringFromDate(startDate!)
      infoLabel.hidden = false
      if let orderInfo = order {
        if orderInfo.status == "0" {
          // 预订状态
          statusLabel.setTitle(" 已经提交订单，请等待酒店确定", forState: .Normal)
          statusLabel.setImage(UIImage(named: "sl_tijiao"), forState: .Normal)
        } else {
          // 确定订单
          statusLabel.setTitle(" 订单已确定，请按时到达酒店", forState: .Normal)
          statusLabel.setImage(UIImage(named: "sl_yuding"), forState: .Normal)
        }
      }
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 点击智键快速聊天，长按智键呼叫服务员", forState: .Normal)
    case .InRegion_NoOrder:
      statusLabel.setTitle(" 欢迎您，点击查看信息", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_dengdai"), forState: .Normal)
      tipsLabel.setTitle(" 按此快速马上预定酒店", forState: UIControlState.Normal)
    case .OutOfRegion_HasOrder_Checkin:
      statusLabel.setTitle(" \((order?.fullname)!)随时为您服务!", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_likai"), forState: .Normal)
      tipsLabel.setTitle(" 点击智键和酒店聊天", forState: .Normal)
    case .OutOfRegion_HasOrder_UnCheckin:
      var startDateString = order?.arrival_date
      var endDateString = order?.departure_date
      var dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.dateFromString(startDateString!)
      let endDate = dateFormatter.dateFromString(endDateString!)
      let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
      dateFormatter.dateFormat = "M/dd"
      startDateString = dateFormatter.stringFromDate(startDate!)
      infoLabel.hidden = false
      if let orderInfo = order {
        if orderInfo.status == "0" {
          // 预订状态
          statusLabel.setTitle(" 已经提交订单，请等待酒店确定", forState: .Normal)
          statusLabel.setImage(UIImage(named: "sl_tijiao"), forState: .Normal)
        } else {
          // 确定订单
          let days = NSDate.daysFromDate(NSDate(), toDate: startDate!)
          if days == 0 {
            statusLabel.setTitle(" 今天入住\((order?.fullname)!)", forState: .Normal)
          } else {
            statusLabel.setTitle(" 请于\(days)天后入住\((order?.fullname)!)", forState: .Normal)
          }
          statusLabel.setImage(UIImage(named: "sl_zhuyi"), forState: .Normal)
        }
      }
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 点击智键和酒店聊天", forState: .Normal)
    case .OutOfRegion_NoOrder:
      statusLabel.setTitle(" 您还没有预订信息, 请立即预订", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_wu"), forState: .Normal)
      tipsLabel.setTitle(" 此快速马上预定酒店", forState: .Normal)
    }
    println("Update Smart Panel")
  }
  
  // MARK: - Button Action
  @IBAction func booking(sender: AnyObject) {
    let navController = UINavigationController(rootViewController: BookHotelListTVC())
    navController.navigationBar.tintColor = UIColor.blackColor()
    navController.navigationBar.translucent = false
    presentViewController(navController, animated: true, completion: nil)
//    navigationController?.pushViewController(BookHotelListTVC(), animated: true)
  }
  
  @IBAction func showSettings(sender: AnyObject) {
//    navigationController?.pushViewController(JSHInfoEditVC(), animated: true)
  }
  
  @IBAction func tappedStatusButton(sender: AnyObject) {
    println("Tap Status Button")
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    switch ruleType {
    case .InRegion_NoOrder, .OutOfRegion_NoOrder:
      navigationController?.pushViewController(BookHotelListTVC(), animated: true)
    case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
      if let orderInfo = order {
        if orderInfo.status == "0" {  // 0 未确认可取消订单
          navigationController?.pushViewController(BookingOrderDetailVC(order: order), animated: true)
        } else {
          navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
        }
      }
      break
    case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
      if let orderInfo = order {
        if orderInfo.status == "0" {  // 0 未确认可取消订单
          navigationController?.pushViewController(BookingOrderDetailVC(order: order), animated: true)
        } else {
          navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
        }
      }
      break
    }
  }
  
  @IBAction func tappedCheckinButton(sender: AnyObject) {
    let order = StorageManager.sharedInstance().lastOrder()
    println("Last Order: \(order)")
    
    if order?.nologin.toInt() == 0 {
      println("立即了解免前台服务")
    } else {
      println("查看免前台特权")
    }
  }
  
  @IBAction func tappedMainButton(sender: AnyObject) {
    println("Tap Main Button")
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    switch ruleType {
    case .InRegion_NoOrder, .OutOfRegion_NoOrder:
//      let chatVC = JSHChatVC(chatType: .Service)
//      chatVC.condition = String(ruleType.rawValue)
//      let navController = UINavigationController(rootViewController: chatVC)
//      navController.navigationBar.tintColor = UIColor.blackColor()
//      navController.navigationBar.translucent = false
//      presentViewController(navController, animated: true, completion: nil)
      break
    case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
      chatVC.shopID = order?.shopid
      chatVC.shopName = order?.fullname
      chatVC.order = order
      chatVC.condition = String(ruleType.rawValue)
      let navController = UINavigationController(rootViewController: chatVC)
      navController.navigationBar.tintColor = UIColor.blackColor()
      navController.navigationBar.translucent = false
      presentViewController(navController, animated: true, completion: nil)
    case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
      chatVC.shopID = order?.shopid
      chatVC.shopName = order?.fullname
      chatVC.order = order
      chatVC.condition = String(ruleType.rawValue)
      let navController = UINavigationController(rootViewController: chatVC)
      navController.navigationBar.tintColor = UIColor.blackColor()
      navController.navigationBar.translucent = false
      presentViewController(navController, animated: true, completion: nil)
    }
  }
  
  @IBAction func longPressedMainButton(sender: AnyObject) {
    if sender.state == UIGestureRecognizerState.Began {
      println("Long Press Main Button.")
      
      let beacon = StorageManager.sharedInstance().lastBeacon()
      let order = StorageManager.sharedInstance().lastOrder()
      
      let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
      switch ruleType {
      case .InRegion_NoOrder, .OutOfRegion_NoOrder:
        return
      case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
        let chatVC = JSHChatVC(chatType: .CallingWaiter)
        chatVC.order = order
        chatVC.shopID = order?.shopid
        chatVC.shopName = order?.fullname
        chatVC.location = beacon!["locdesc"]
        let navController = UINavigationController(rootViewController: chatVC)
        navController.navigationBar.tintColor = UIColor.blackColor()
        navController.navigationBar.translucent = false
        presentViewController(navController, animated: true, completion: nil)
      case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
//        let chatVC = JSHChatVC(chatType: .CallingWaiter)
//        chatVC.order = order
//        chatVC.location = "不在酒店"
//        let navController = UINavigationController(rootViewController: chatVC)
//        navController.navigationBar.tintColor = UIColor.blackColor()
//        navController.navigationBar.translucent = false
//        presentViewController(navController, animated: true, completion: nil)
        break
      }
    }
  }
  
  @IBAction func didSelectLeftButton(sender: AnyObject) {
    sideMenuViewController.presentLeftMenuViewController()
  }
  
  @IBAction func didSelectRightButton(sender: AnyObject) {
    sideMenuViewController.presentRightMenuViewController()
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedAlways {
      setupBeaconMonitor()
      setupGPSMonitor()
    }
    println("didChangeAuthorizationStatus: \(status.rawValue)")
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("Error while updating location " + error.localizedDescription)
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    locationManager.stopMonitoringSignificantLocationChanges()
    let coordinate = manager.location.coordinate
    let regeoRequest: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
    regeoRequest.searchType = AMapSearchType.ReGeocode
    regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
    regeoRequest.radius = 10000
    regeoRequest.requireExtension = true
    println("regeoRequest :\(regeoRequest)")
    locationSearch.AMapReGoecodeSearch(regeoRequest)
    
    postGPSLocation(coordinate)
  }
  
  func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
    if region.identifier == "DetermineCurrentRegionState" {
      println("didDetermineState: \(state.rawValue)")
      if state != CLRegionState.Inside {
        StorageManager.sharedInstance().updateLastBeacon(nil)
      }
      updateSmartPanelUI()
    }
  }
  
  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    if region is CLBeaconRegion {
      didEnterBeaconRegion(region as! CLBeaconRegion)
    }
    println("didEnterRegion: \(region)")
  }
  
  func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    if region is CLBeaconRegion {
      didExitBeaconRegion(region as! CLBeaconRegion)
    }
    println("didExitRegion: \(region)")
  }
  
  // MARK: - AMapSearchDelegate
  func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
    
    if (response.regeocode != nil) {
      var title = response.regeocode.addressComponent.city
      var length: Int{
        return count(title)
      }
      
      if (length == 0){
        title = response.regeocode.addressComponent.province
      }
      println("Location: \(response.regeocode.formattedAddress)")
    }
  }
  
  // MARK: - UINavigationControllerDelegate
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
//    if operation == UINavigationControllerOperation.Push && toVC is JSHInfoEditVC {
//      return JSHAnimator()
//    }
    return nil
  }
  
}
