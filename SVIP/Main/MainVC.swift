//
//  MainVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class MainVC: UIViewController, CRMotionViewDelegate, ESTBeaconManagerDelegate {
  
  @IBOutlet weak var mainButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: MIBadgeButton!
  
  @IBOutlet weak var roomType: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var duration: UILabel!
  @IBOutlet weak var statusLogo: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!
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
    
    rightButton.badgeEdgeInsets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 3.0)
    rightButton.badgeBackgroundColor = UIColor.redColor()
    rightButton.badgeString = "1"
    
    let motionView = YXTMotionView(frame: UIScreen.mainScreen().bounds, image: UIImage(named: "星空中心"))
    motionView.delegate = self
    motionView.motionEnabled = true
    motionView.scrollIndicatorEnabled = false
    motionView.zoomEnabled = false
    motionView.scrollDragEnabled = false
    motionView.scrollBounceEnabled = false
    self.view.addSubview(motionView)
    self.view.sendSubviewToBack(motionView)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupBeaconMonitor", name:"ZKJSSetupBeaconRegions", object: nil)
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
//          didEnterBeaconRegion(beaconRegion)
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
  }
  
  // MARK: - Button Action
  @IBAction func didSelectMainButton(sender: AnyObject) {
    let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let dictionary: [String: AnyObject] = [
      "type": MessagePushType.PushLoc_IOS_A2M.rawValue,
      "devtoken": "2327ad9f487b67fe262941c08e2069fbb6ecc47883a049a260e7155020880ef2",
      "appid": "HOTELVIP",
      "userid": "557cff54a9a97",
      "shopid": "120",
      "locid": "1",
      "username": "金石",
      "timestamp": NSNumber(longLong: timestamp)
    ]
    ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
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
  func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
    didEnterBeaconRegion(region)
  }
  
  func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
    didExitBeaconRegion(region)
  }
  
}
