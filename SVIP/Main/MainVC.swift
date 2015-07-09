//
//  MainVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UINavigationControllerDelegate, CRMotionViewDelegate, ESTBeaconManagerDelegate {
  
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var settingsButton: UIButton!
  
  @IBOutlet weak var mainButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: MIBadgeButton!

  @IBOutlet weak var statusLabel: UIButton!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var tipsLabel: UIButton!
  
  let beaconManager = ESTBeaconManager()
  
  var beaconRegions = [String: [String: String]]()
  
  func scrollViewDidScrollToOffset(offset: CGPoint) {
    println(offset)
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let motionView = YXTMotionView(frame: UIScreen.mainScreen().bounds, image: UIImage(named: "星空中心"))
    println("Bounds: \(UIScreen.mainScreen().bounds)")
    motionView.delegate = self
    motionView.motionEnabled = true
    motionView.scrollIndicatorEnabled = false
    motionView.zoomEnabled = false
    motionView.scrollDragEnabled = false
    motionView.scrollBounceEnabled = false
    self.view.addSubview(motionView)
    self.view.sendSubviewToBack(motionView)
    
    rightButton.badgeEdgeInsets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 3.0)
    rightButton.badgeBackgroundColor = UIColor.redColor()
    rightButton.badgeString = nil
    
    setupBeaconMonitor()
    
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.delegate = self;
    avatarImage.image = JSHStorage.baseInfo().avatarImage
    
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    ZKJSHTTPSessionManager.sharedInstance().getOrderListWithUserID(userID, token: token, page: "1", success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let orderArray = responseObject as! NSArray
      if orderArray.count > 0 {
        let lastOrder = orderArray.firstObject as! NSDictionary
        var order = [String: String]()
        order["status"] = lastOrder["status"] as? String
        order["arrival_date"] = lastOrder["arrival_date"] as? String
        order["departure_date"] = lastOrder["departure_date"] as? String
        order["room_type"] = lastOrder["room_type"] as? String
        order["guest"] = lastOrder["guest"] as? String
        order["guesttel"] = lastOrder["guesttel"] as? String
        order["reservation_no"] = lastOrder["reservation_no"] as? String
        order["room_rate"] = lastOrder["room_rate"] as? String
        StorageManager.sharedInstance().updateLastOrder(order)
      } else {
        StorageManager.sharedInstance().updateLastOrder(nil)
      }
      self.determineCurrentRegionState()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
    
    if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
      rightButton.badgeString = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
    }
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
        beaconManager.requestStateForRegion(beaconRegion)
      } else if minor == 0 {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), identifier: identifier)
        beaconManager.requestStateForRegion(beaconRegion)
      } else {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
        beaconManager.requestStateForRegion(beaconRegion)
      }
    } else {
      self.updateSmartPanel()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.delegate = nil
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Private Method
  func setupBeaconMonitor() {
    beaconManager.delegate = self
    
    beaconRegions = StorageManager.sharedInstance().beaconRegions()
    
    if ESTBeaconManager.authorizationStatus() == .NotDetermined {
      beaconManager.requestAlwaysAuthorization()
    } else if ESTBeaconManager.authorizationStatus() == .Denied {
      let alert = UIAlertView(title: "Location Access Denied", message: "You have denied access to location services. Change this in app settings.", delegate: nil, cancelButtonTitle: "OK")
      alert.show()
    } else if ESTBeaconManager.authorizationStatus() == .Restricted {
      let alert = UIAlertView(title: "Location Not Available", message: "You have no access to location services.", delegate: nil, cancelButtonTitle: "OK")
      alert.show()
    }
    
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
          beaconManager.startMonitoringForRegion(beaconRegion)
        } else if minor == 0 {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          beaconManager.startMonitoringForRegion(beaconRegion)
        } else {
          let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid!), major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
          beaconRegion.notifyOnExit = true
          beaconRegion.notifyOnEntry = true
          beaconManager.startMonitoringForRegion(beaconRegion)
        }
      }
    }
  }
  
  func didEnterBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    if let beaconRegion = beaconRegions[region.identifier] {
      ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
      let shopID = beaconRegion["shopid"]
      let locid = beaconRegion["locid"]
      let uuid = beaconRegion["uuid"]
      let major = beaconRegion["major"]
      let minor = beaconRegion["minor"]
      
      let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(1 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        let dictionary: [String: AnyObject] = [
          "type": MessagePushType.PushLoc_IOS_A2M.rawValue,
          "devtoken": "2327ad9f487b67fe262941c08e2069fbb6ecc47883a049a260e7155020880ef2",
          "appid": "HOTELVIP",
          "userid": "557cff54a9a97",
          "shopid": shopID!,
          "locid": locid!,
          "username": "金石",
          "timestamp": NSNumber(longLong: timestamp)
        ]
        ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
        
        let notification = UILocalNotification()
        let alertMessage = "Enter region notification ShopID: \(shopID!) LocationID: \(locid!) UUID: \(uuid!) Major: \(major!) Minor: \(minor!)"
        notification.alertBody = alertMessage
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
      }
      StorageManager.sharedInstance().updateLastBeacon(beaconRegion)
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
      
      let notification = UILocalNotification()
      let alertMessage = "Exit region notification ShopID: \(shopID!) LocationID: \(locid!) UUID: \(uuid!) Major: \(major!) Minor: \(minor!)"
      notification.alertBody = alertMessage
      UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    StorageManager.sharedInstance().updateLastBeacon(nil)
  }
  
  func updateSmartPanel() {
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    var startDateString = order!["arrival_date"]
    var endDateString = order!["departure_date"]
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(startDateString!)
    let endDate = dateFormatter.dateFromString(endDateString!)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    dateFormatter.dateFormat = "M/dd"
    startDateString = dateFormatter.stringFromDate(startDate!)
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    infoLabel.hidden = true
    switch ruleType {
    case .InRegion_HasOrder_Checkin:
      statusLabel.setTitle(" 您已经到达酒店大堂", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_ruzhu"), forState: .Normal)
      var roomType = ""
      if let room_type = order!["room_type"] {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 长按智键呼叫服务员，单击发送消息", forState: .Normal)
    case .InRegion_HasOrder_UnCheckin:
      infoLabel.hidden = false
      statusLabel.setTitle(" 您已经到达酒店大堂,请办理入住手续", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_dating"), forState: .Normal)
      var roomType = ""
      if let room_type = order!["room_type"] {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 长按智键呼叫服务员，单击发送消息", forState: .Normal)
    case .InRegion_NoOrder:
      statusLabel.setTitle(" 您已经在酒店大堂,请尽快预订酒店", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_dating"), forState: .Normal)
      tipsLabel.setTitle(" 点击智键预订酒店", forState: UIControlState.Normal)
    case .OutOfRegion_HasOrder_Checkin:
      statusLabel.setTitle(" 您不在酒店,请注意保管好财物", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_ruzhu"), forState: .Normal)
      tipsLabel.setTitle(" 长按智键呼叫服务员，单击发送消息", forState: .Normal)
    case .OutOfRegion_HasOrder_UnCheckin:
      infoLabel.hidden = false
      statusLabel.setTitle(" 请注意您的行程,按时入住酒店", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_dengdai"), forState: .Normal)
      var roomType = ""
      if let room_type = order!["room_type"] {
        roomType = room_type
      }
      let date = "\(startDateString!)入住"
      let duration = "\(days)晚"
      infoLabel.text = "\(roomType) | \(date) | \(duration)";
      infoLabel.sizeToFit()
      tipsLabel.setTitle(" 长按智键呼叫服务员，单击发送消息", forState: .Normal)
    case .OutOfRegion_NoOrder:
      statusLabel.setTitle(" 您没有任何预订信息", forState: .Normal)
      statusLabel.setImage(UIImage(named: "sl_wu"), forState: .Normal)
      tipsLabel.setTitle(" 请按智键进行预订", forState: .Normal)
    }
    println("Update Smart Panel")
  }
  
  // MARK: - Button Action
  @IBAction func showSettings(sender: AnyObject) {
    navigationController?.pushViewController(JSHInfoEditVC(), animated: true)
  }
  
  @IBAction func tappedMainButton(sender: AnyObject) {
    println("Tap Main Button")
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    
    let ruleType = RuleEngine.sharedInstance().getRuleType(order, beacon: beacon)
    switch ruleType {
    case .InRegion_NoOrder, .OutOfRegion_NoOrder:
      let navController = UINavigationController(rootViewController: BookVC())
      navController.navigationBar.tintColor = UIColor.blackColor()
      navController.navigationBar.translucent = false
      presentViewController(navController, animated: true, completion: nil)
    case .InRegion_HasOrder_Checkin, .InRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
      chatVC.condition = String(ruleType.rawValue)
      let navController = UINavigationController(rootViewController: chatVC)
      navController.navigationBar.tintColor = UIColor.blackColor()
      navController.navigationBar.translucent = false
      presentViewController(navController, animated: true, completion: nil)
    case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
      let chatVC = JSHChatVC(chatType: .Service)
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
        chatVC.location = beacon!["locdesc"]
        let navController = UINavigationController(rootViewController: chatVC)
        navController.navigationBar.tintColor = UIColor.blackColor()
        navController.navigationBar.translucent = false
        presentViewController(navController, animated: true, completion: nil)
      case .OutOfRegion_HasOrder_Checkin, .OutOfRegion_HasOrder_UnCheckin:
        let chatVC = JSHChatVC(chatType: .CallingWaiter)
        chatVC.location = "不在酒店"
        let navController = UINavigationController(rootViewController: chatVC)
        navController.navigationBar.tintColor = UIColor.blackColor()
        navController.navigationBar.translucent = false
        presentViewController(navController, animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func didSelectLeftButton(sender: AnyObject) {
    let navController = UINavigationController(rootViewController: OrderListTVC())
    navController.navigationBar.tintColor = UIColor.blackColor()
    navController.navigationBar.translucent = false
    presentViewController(navController, animated: true, completion: nil)
  }
  
  @IBAction func didSelectRightButton(sender: AnyObject) {
    let navController = UINavigationController(rootViewController: MessageCenterTVC())
    navController.navigationBar.tintColor = UIColor.blackColor()
    navController.navigationBar.translucent = false
    presentViewController(navController, animated: true, completion: nil)
  }
  
  // MARK: - ESTBeaconManagerDelegate
  func beaconManager(manager: AnyObject!, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion!) {
    if region.identifier == "DetermineCurrentRegionState" {
      println(state.rawValue)
      if state != CLRegionState.Inside {
        StorageManager.sharedInstance().updateLastBeacon(nil)
      }
      self.updateSmartPanel()
    }
  }
  
  func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
    didEnterBeaconRegion(region)
  }
  
  func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
    didExitBeaconRegion(region)
  }
  
  // MARK: - UINavigationControllerDelegate
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    if operation == UINavigationControllerOperation.Push {
      return JSHAnimator()
    }
    return nil
  }
  
}
