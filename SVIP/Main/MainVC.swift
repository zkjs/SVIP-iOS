//
//  MainVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class MainVC: UIViewController, UINavigationControllerDelegate, CRMotionViewDelegate, CLLocationManagerDelegate/*, AMapSearchDelegate*/, CBCentralManagerDelegate {
  
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
//  var locationSearch = AMapSearchAPI()
  var bluetoothManager = CBCentralManager()
  
  // MARK: - View Lifecycle
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNotification()
    setupCoreLocationService()
    setupMotionView()
    setupRightButton()
//    initTCPSessionManager()
    initSmartPanelUI()
    setupBluetoothManager()
    
//    testGPSBasedNotification()
    
    print("userid: \(JSHAccountManager.sharedJSHAccountManager().userid)")
    print("token: \(JSHAccountManager.sharedJSHAccountManager().token)")
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: true)//为了保证每次进入首页无navigationbar页面效果
    navigationController?.delegate = self
    
    setupAvatarImage()
    setupLeftRightButtons()
    updateSmartPanel()
    updateMessageBadge()
  }
  
  func setupAvatarImage() {
    settingsButton.imageView?.contentMode = .ScaleAspectFit
    if let image = JSHStorage.baseInfo().avatarImage {
      settingsButton.setImage(image, forState: .Normal)
    } else {
      let userid = JSHStorage.baseInfo().userid
      var url = NSURL(string: kBaseURL)
      url = url?.URLByAppendingPathComponent("uploads/users/\(userid).jpg")
      settingsButton.sd_setImageWithURL(url,
                                        forState: .Normal,
                                        placeholderImage: UIImage(named: "ic_camera_nor"),
                                        options: [.RetryFailed, .ProgressiveDownload, .HighPriority])
    }
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
    print(offset)
  }
  
  // MARK: - Private Method
  
  private func initSmartPanelUI() {
    statusLabel.hidden = true
    infoLabel.hidden = true
//    tipsLabel.hidden = true
    regionLabel.hidden = true
    checkinLabel.hidden = true
    checkinSubLabel.hidden = true
  }
  
  private func initTCPSessionManager() {
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
  }
  
  private func setupNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSmartPanel", name: "UIApplicationDidBecomeActiveNotification", object: nil)
  }
  
  private func setupLeftRightButtons() {
    if NSUserDefaults.standardUserDefaults().boolForKey("isFirstRun") {
      leftButton.hidden = false
      rightButton.hidden = false
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstRun")
    } else {
      leftButton.hidden = true
      rightButton.hidden = true
    }
  }
  
  private func setupRightButton() {
    rightButton.badgeEdgeInsets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 3.0)
    rightButton.badgeBackgroundColor = UIColor.redColor()
    rightButton.badgeString = nil
  }
  
  private func setupMotionView() {
    let motionView = YXTMotionView(frame: UIScreen.mainScreen().bounds, image: UIImage(named: "星空中心"))
    print("Bounds: \(UIScreen.mainScreen().bounds)")
    motionView.delegate = self
    motionView.motionEnabled = true
    motionView.scrollIndicatorEnabled = false
    motionView.zoomEnabled = false
    motionView.scrollDragEnabled = false
    motionView.scrollBounceEnabled = false
    view.addSubview(motionView)
    view.sendSubviewToBack(motionView)
  }
  
  private func setupCoreLocationService() {
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
    print("setupCoreLocationService")
  }
  
  private func removeAllMonitoredRegions() {
    for monitoredRegion in locationManager.monitoredRegions {
      let region = monitoredRegion as! CLBeaconRegion
      locationManager.stopMonitoringForRegion(region)
    }
  }
  
  private func setupBeaconMonitor() {
    removeAllMonitoredRegions()
    
    beaconRegions = StorageManager.sharedInstance().beaconRegions()
    for key in beaconRegions.keys {
      if let beaconInfo = beaconRegions[key] {
        let uuid = beaconInfo["uuid"]
        let majorString = beaconInfo["major"]
        let minorString = beaconInfo["minor"]
        let identifier = key
        var major = 0
        var minor = 0
        if let majorValue = Int((majorString)!) {
          major = majorValue
        }
        if let minorValue = Int((minorString)!) {
          minor = minorValue
        }
        
        if minor == 0 && major == 0 {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          locationManager.startMonitoringForRegion(beaconRegion)
        } else if minor == 0 {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, major: CLBeaconMajorValue(major), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          locationManager.startMonitoringForRegion(beaconRegion)
        } else {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          locationManager.startMonitoringForRegion(beaconRegion)
        }
      }
    }
    print("已监控的Beacon区域:\(locationManager.monitoredRegions)")
  }
  
  private func setupGPSMonitor() {
    locationManager.startMonitoringSignificantLocationChanges()
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    locationManager.startUpdatingLocation()
//    locationSearch = AMapSearchAPI(searchKey: "7945ba33067bb07845e8a60d12135885", delegate: self)
    
//    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "57CD9454-6261-4838-8A48-B01A2DE08A42"), identifier: "TestRanging")
//    locationManager.startRangingBeaconsInRegion(beaconRegion)
  }
  
  private func determineCurrentRegionState() {
    if let beaconInfo = StorageManager.sharedInstance().lastBeacon() {
      let uuid = beaconInfo["uuid"]
      let majorString = beaconInfo["major"]
      let minorString = beaconInfo["minor"]
      let identifier = "DetermineCurrentRegionState"
      var major = 0
      var minor = 0
      if let majorValue = Int((majorString)!) {
        major = majorValue
      }
      if let minorValue = Int((minorString)!) {
        minor = minorValue
      }
      if minor == 0 && major == 0 {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      } else if minor == 0 {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, major: CLBeaconMajorValue(major), identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      } else {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!)!, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
        locationManager.requestStateForRegion(beaconRegion)
      }
    }
    updateSmartPanelUI()
  }
  
  private func didEnterBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    if let beaconRegion = beaconRegions[region.identifier] {
      let lastSendDate = NSUserDefaults.standardUserDefaults().objectForKey(region.identifier) as? NSDate
      print(region.identifier + " Last Send Date: \(lastSendDate)" + " Now: \(NSDate())")
      // 如果10分钟内再次触发该区域，则不发推送
      if lastSendDate == nil || NSDate().timeIntervalSinceDate(lastSendDate!) >= 60 * 10 {
        StorageManager.sharedInstance().updateLastBeacon(beaconRegion)
        if UIApplication.sharedApplication().applicationState == .Background {
          NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ShouldSendEnterBeaconRegionPacket")
          ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
        } else {
          sendEnterRegionPacketWithBeacon(beaconRegion)
        }
      }
    }
  }
  
  private func didExitBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    if let beaconRegion = beaconRegions[region.identifier] {
      StorageManager.sharedInstance().updateLastBeacon(beaconRegion)
      if UIApplication.sharedApplication().applicationState == .Background {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ShouldSendExitBeaconRegionPacket")
        ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
      } else {
        sendExitRegionPacketWithBeacon(beaconRegion)
      }
    }
  }
  
  private func updateMessageBadge() {
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
  
  private func postGPSLocation(coordinate: CLLocationCoordinate2D) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let traceTime = dateFormatter.stringFromDate(NSDate())
    ZKJSHTTPSessionManager.sharedInstance().postGPSWithLongitude("\(coordinate.longitude)", latitude: "\(coordinate.latitude)", traceTime: traceTime, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
//    let notification = UILocalNotification()
//    let alertMessage = "\(coordinate.latitude), \(coordinate.longitude), \(traceTime)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  private func updateSmartPanelUI() {
    statusLabel.hidden = false
    infoLabel.hidden = false
//    tipsLabel.hidden = false
    regionLabel.hidden = false
    checkinLabel.hidden = false
//    checkinSubLabel.hidden = false
    
    let beacon = StorageManager.sharedInstance().lastBeacon()
    print("Last Beacon: \(beacon)")
    let order = StorageManager.sharedInstance().lastOrder()
    print("Last Order: \(order)")
    
    if beacon != nil {
      regionLabel.text = beacon!["locdesc"]
    } else {
      regionLabel.text = NSLocalizedString("OUTSIDE_HOTEL", comment: "")
    }
    
    // 免前台
    checkinLabel.setTitle(NSLocalizedString("CHECKIN_LABEL_NO_IN_ROOM_CHECKIN", comment: ""), forState: .Normal)
//    checkinSubLabel.text = "立即了解"
    if let nologin = order?.nologin {
      if Int(nologin) == 1 {
        checkinLabel.setTitle(NSLocalizedString("CHECKIN_LABEL_IN_ROOM_CHECKIN", comment: ""), forState: .Normal)
//        checkinSubLabel.text = "立即查看"
      }
    }
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    infoLabel.hidden = true
    switch ruleType {
    case .InRegion_HasOrder_Checkin:  //在酒店-已入住
      var startDateString = order?.arrival_date
      let endDateString = order?.departure_date
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.dateFromString(startDateString!)
      let endDate = dateFormatter.dateFromString(endDateString!)
      let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
      dateFormatter.dateFormat = "M/dd"
      startDateString = dateFormatter.stringFromDate(startDate!)
      if NSDate.daysFromDate(NSDate(), toDate: endDate!) == 0 {
        // 退房状态
        statusLabel.setTitle(NSLocalizedString("InRegion_HasOrder_Checkin_NEED_CHECKOUT", comment: ""), forState: .Normal)
        statusLabel.setImage(UIImage(named: "sl_tuifang"), forState: .Normal)
      } else {
        // 入住状态
//        if let location = beacon!["locdesc"] {
//          if location.isEmpty {
            statusLabel.setTitle(String(format: NSLocalizedString("InRegion_HasOrder_Checkin", comment: ""),
                                        arguments: [(order?.fullname)!]),
                                 forState: .Normal)
//          } else {
//            statusLabel.setTitle(" 您已到达\(location)，旅途愉快", forState: .Normal)
//          }
//        }
        statusLabel.setImage(UIImage(named: "sl_ruzhu"), forState: .Normal)
      }
      
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)" + NSLocalizedString("CHECKIN_TIME", comment: "")
      let duration = "\(days)" + NSLocalizedString("NIGHT", comment: "")
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
//      tipsLabel.setTitle(" 点击智键快速聊天，长按智键呼叫服务员", forState: .Normal)
    case .InRegion_HasOrder_UnCheckin:  //在酒店-未入住
      var startDateString = order?.arrival_date
      let endDateString = order?.departure_date
      let dateFormatter = NSDateFormatter()
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
          statusLabel.setTitle(NSLocalizedString("InRegion_HasOrder_UnCheckin_BOOKING", comment: ""), forState: .Normal)
          statusLabel.setImage(UIImage(named: "sl_tijiao"), forState: .Normal)
        } else {
          // 确定订单
          if Int((order?.nologin)!) == 0 {
            statusLabel.setTitle(NSLocalizedString("InRegion_HasOrder_UnCheckin_IN_ROOM_CHECK_IN", comment: ""), forState: .Normal)
          } else {
            statusLabel.setTitle(NSLocalizedString("InRegion_HasOrder_UnCheckin_NO_IN_ROOM_CHECK_IN", comment: ""), forState: .Normal)
          }
          statusLabel.setImage(UIImage(named: "sl_yuding"), forState: .Normal)
        }
      }
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)" + NSLocalizedString("CHECKIN_TIME", comment: "")
      let duration = "\(days)" + NSLocalizedString("NIGHT", comment: "")
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
//      tipsLabel.setTitle(" 点击智键快速聊天，长按智键呼叫服务员", forState: .Normal)
    case .InRegion_NoOrder:  // 在酒店-无订单
      if let shopID = beacon!["shopid"] {
        if let shopName = StorageManager.sharedInstance().shopNameWithShopID(shopID) {
          statusLabel.setTitle(String(format: NSLocalizedString("InRegion_NoOrder", comment: ""), arguments: [shopName]),
                               forState: .Normal)
        }
      }
      statusLabel.setImage(UIImage(named: "sl_dengdai"), forState: .Normal)
//      tipsLabel.setTitle(" 按此快速马上预定酒店", forState: UIControlState.Normal)
    case .OutOfRegion_HasOrder_Checkin:  // 不在酒店-已入住
      statusLabel.setTitle(String(format: NSLocalizedString("OutOfRegion_HasOrder_Checkin", comment: ""), arguments: [(order?.fullname)!]),
                           forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_likai"), forState: .Normal)
//      tipsLabel.setTitle(" 点击智键和酒店聊天", forState: .Normal)
    case .OutOfRegion_HasOrder_UnCheckin:  // 不在酒店-未入住
      var startDateString = order?.arrival_date
      let endDateString = order?.departure_date
      let dateFormatter = NSDateFormatter()
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
          statusLabel.setTitle(NSLocalizedString("OutOfRegion_HasOrder_UnCheckin_BOOKING", comment: ""), forState: .Normal)
          statusLabel.setImage(UIImage(named: "sl_tijiao"), forState: .Normal)
        } else {
          // 确定订单
          let days = NSDate.daysFromDate(NSDate(), toDate: startDate!)
          if days == 0 {
            statusLabel.setTitle(String(format: NSLocalizedString("OutOfRegion_HasOrder_UnCheckin_CHECKIN_TODAY", comment: ""), arguments: [(order?.fullname)!]),
                                 forState: .Normal)
          } else {
            statusLabel.setTitle(String(format: " 请于%d天后入住%@", arguments: [days, (order?.fullname)!]),
                                 forState: .Normal)
          }
          statusLabel.setImage(UIImage(named: "sl_zhuyi"), forState: .Normal)
        }
      }
      var roomType = ""
      if let room_type = order?.room_type {
        roomType = room_type
      }
      let date = "\(startDateString!)" + NSLocalizedString("CHECKIN_TIME", comment: "")
      let duration = "\(days)" + NSLocalizedString("NIGHT", comment: "")
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
//      tipsLabel.setTitle(" 点击智键和酒店聊天", forState: .Normal)
    case .OutOfRegion_NoOrder:  // 不在酒店-无订单
      statusLabel.setTitle(NSLocalizedString("OutOfRegion_NoOrder", comment: ""), forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_wu"), forState: .Normal)
//      tipsLabel.setTitle(" 此快速马上预定酒店", forState: .Normal)
    }
    print("Update Smart Panel")
  }
  
  private func sendEnterRegionPacketWithBeacon(beacon: [String: String]) {
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
  
  private func sendExitRegionPacketWithBeacon(beacon: [String: String]) {
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
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  private func testGPSBasedNotification() {
    // 测试基于经纬度的位置提醒
    let localNotification = UILocalNotification()
    localNotification.alertBody = "欢迎来到中科院先进所.."
    localNotification.regionTriggersOnce = false
    let coordinate = CLLocationCoordinate2D(latitude: 22.599119, longitude: 113.985428)
    let region = CLCircularRegion(center: coordinate, radius: 100, identifier: "Test_Location_Notification")
    region.notifyOnEntry = true
    region.notifyOnExit = false
    localNotification.region = region
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  // MARK: - Public 
  
  func updateSmartPanel() {
    ZKJSHTTPSessionManager.sharedInstance().getLatestOrderWithSuccess({ [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        let lastOrder = responseObject as! NSDictionary
        if let reservation_no = lastOrder["reservation_no"] as? String {
          if reservation_no == "0" {
            StorageManager.sharedInstance().updateLastOrder(nil)
          } else {
            let order = BookOrder(dictionary: responseObject as! NSDictionary)
            StorageManager.sharedInstance().updateLastOrder(order)
          }
        }
        self.determineCurrentRegionState()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  // MARK: - Button Action
  
  @IBAction func booking(sender: AnyObject) {
    navigationController?.pushViewController(BookHotelListTVC(), animated: true)
  }
  
  @IBAction func showSettings(sender: AnyObject) {
    let vc = SettingTableViewController(style: UITableViewStyle.Grouped)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tappedStatusButton(sender: AnyObject) {
    print("Tap Status Button")
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    switch ruleType {
    case .InRegion_NoOrder:
      let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
      vc.shopID = beacon!["shopid"]!
      self.navigationController?.pushViewController(vc, animated: true)
      break
    case .OutOfRegion_NoOrder:
      navigationController?.pushViewController(BookHotelListTVC(), animated: true)
    case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
      if let orderInfo = order {
        if orderInfo.status == "0" {  // 0 未确认可取消订单
          navigationController?.pushViewController(BookingOrderDetailVC(order: order), animated: true)
        } else {
          navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
        }
      }
    case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
      if let orderInfo = order {
        if orderInfo.status == "0" {  // 0 未确认可取消订单
          navigationController?.pushViewController(BookingOrderDetailVC(order: order), animated: true)
        } else {
          navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
        }
      }
    }
  }
  
  @IBAction func tappedCheckinButton(sender: AnyObject) {
    let order = StorageManager.sharedInstance().lastOrder()
    print("Last Order: \(order)")
    
//    let storyboard = UIStoryboard(name: "BookingOrderDetail", bundle: nil)
//    let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderDetailTVC") as! BookingOrderDetailTVC
//    navigationController?.pushViewController(vc, animated: true)
    
    let vc = SkipCheckInSettingViewController()
    if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
      self.sideMenuViewController.hideMenuViewController()
      navi.pushViewController(vc, animated: true)
    }
  }
  
  @IBAction func tappedMainButton(sender: AnyObject) {
    print("Tap Main Button")
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    switch ruleType {
    case .InRegion_NoOrder, .OutOfRegion_NoOrder:
      sideMenuViewController.presentRightMenuViewController()
    case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
      chatVC.shopID = order?.shopid
      chatVC.shopName = order?.fullname
      chatVC.order = order
      chatVC.condition = String(ruleType.rawValue)
      navigationController?.pushViewController(chatVC, animated: true)
    case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
      chatVC.shopID = order?.shopid
      chatVC.shopName = order?.fullname
      chatVC.order = order
      chatVC.condition = String(ruleType.rawValue)
      navigationController?.pushViewController(chatVC, animated: true)
    }

#if DEBUG
  let appid = "SVIP_DEBUG"
  let timestamp = Int64(NSDate().timeIntervalSince1970)
  let userID = JSHAccountManager.sharedJSHAccountManager().userid
  let userName = JSHStorage.baseInfo().username ?? ""
  let deviceToken = JSHStorage.deviceToken()
  let dictionary: [String: AnyObject] = [
    "type": MessagePushType.PushLoc_IOS_A2M.rawValue,
    "devtoken": deviceToken,
    "appid": appid,
    "userid": userID,
    "shopid": "120",
    "locid": "6",
    "locdesc": "大堂",
    "username": userName,
    "timestamp": NSNumber(longLong: timestamp)
  ]
  ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
#endif
  }
  
  @IBAction func longPressedMainButton(sender: AnyObject) {
    if sender.state == UIGestureRecognizerState.Began {
      print("Long Press Main Button.")
      
      let beacon = StorageManager.sharedInstance().lastBeacon()
      let order = StorageManager.sharedInstance().lastOrder()

      let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
      switch ruleType {
      case .InRegion_NoOrder, .OutOfRegion_NoOrder:
        let bookHotelList = BookHotelListTVC()
        bookHotelList.style = .PhoneCall
        navigationController?.pushViewController(bookHotelList, animated: true)
      case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
//        let chatVC = JSHChatVC(chatType: .CallingWaiter)
//        chatVC.order = order
//        chatVC.shopID = order?.shopid
//        chatVC.shopName = order?.fullname
//        chatVC.location = beacon!["locdesc"]
//        let navController = UINavigationController(rootViewController: chatVC)
//        navController.navigationBar.tintColor = UIColor.blackColor()
//        navController.navigationBar.translucent = false
//        presentViewController(navController, animated: true, completion: nil)
        // 拨打酒店电话
        if let shopID = order?.shopid {
          if let shopPhone = StorageManager.sharedInstance().shopPhoneWithShopID(shopID) {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(shopPhone)")!)
          }
        }
      case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
//        let chatVC = JSHChatVC(chatType: .CallingWaiter)
//        chatVC.order = order
//        chatVC.location = "不在酒店"
//        let navController = UINavigationController(rootViewController: chatVC)
//        navController.navigationBar.tintColor = UIColor.blackColor()
//        navController.navigationBar.translucent = false
//        presentViewController(navController, animated: true, completion: nil)
        // 拨打酒店电话
        if let shopID = order?.shopid {
          if let shopPhone = StorageManager.sharedInstance().shopPhoneWithShopID(shopID) {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(shopPhone)")!)
          }
        }
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
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status != CLAuthorizationStatus.AuthorizedAlways {
//      let alertView = UIAlertController(title: "无法获取位置", message: "我们将为您提供免登记办理入住手续，该项服务需要使用定位功能，需要您前往设置中心打开定位服务", preferredStyle: .Alert)
//      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
//      presentViewController(alertView, animated: true, completion: nil)
    }
    print("didChangeAuthorizationStatus: \(status.rawValue)")
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error while updating location " + error.localizedDescription)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopMonitoringSignificantLocationChanges()
    let coordinate = manager.location!.coordinate
    
//    let regeoRequest: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
//    regeoRequest.searchType = AMapSearchType.ReGeocode
//    regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
//    regeoRequest.radius = 10000
//    regeoRequest.requireExtension = true
//    print("regeoRequest :\(regeoRequest)")
//    locationSearch.AMapReGoecodeSearch(regeoRequest)
    
    postGPSLocation(coordinate)
  }
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
    if region.identifier == "DetermineCurrentRegionState" {
      print("didDetermineState: \(state.rawValue)")
      if state != CLRegionState.Inside {
        StorageManager.sharedInstance().updateLastBeacon(nil)
      }
      updateSmartPanelUI()
    }
  }
  
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLBeaconRegion {
      didEnterBeaconRegion(region as! CLBeaconRegion)
    }
    print("didEnterRegion: \(region)")
  }
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLBeaconRegion {
      didExitBeaconRegion(region as! CLBeaconRegion)
    }
    print("didExitRegion: \(region)")
  }
  
//  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
//    println(beacons.first)
//  }
//  
  
  // MARK: - CBCentralManagerDelegate
  
  func centralManagerDidUpdateState(central: CBCentralManager) {
    switch central.state {
    case .PoweredOn:
      print(".PoweredOn")
    case .PoweredOff:
      print(".PoweredOff")
//      let alertView = UIAlertController(title: "请打开蓝牙", message: "我们将为您提供免登记办理入住手续等贴心服务需要使用蓝牙功能", preferredStyle: .Alert)
//      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
//      presentViewController(alertView, animated: true, completion: nil)
    case .Resetting:
      print(".Resetting")
    case .Unauthorized:
      print(".Unauthorized")
    case .Unknown:
      print(".Unknown")
    case .Unsupported:
      print(".Unsupported")
    }
  }
  
//  // MARK: - AMapSearchDelegate
//  
//  func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
//    
//    if (response.regeocode != nil) {
//      var title = response.regeocode.addressComponent.city
//      var length: Int{
//        return title.characters.count
//      }
//      
//      if (length == 0){
//        title = response.regeocode.addressComponent.province
//      }
//      print("Location: \(response.regeocode.formattedAddress)")
//    }
//  }
  
  // MARK: - UINavigationControllerDelegate
  
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
//    if operation == UINavigationControllerOperation.Push && toVC is SettingTableViewController {
//      return JSHAnimator()
//    }
    
    return nil
  }
  
}
