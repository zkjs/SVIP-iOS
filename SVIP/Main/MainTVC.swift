//
//  MainTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class MainTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DCPathButtonDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate {

  var localBaseInfo :JSHBaseInfo?
  var order = BookOrder()
  var height:CGFloat!
  var distance:CLLocationDistance!
  var longitude:double_t!
  var latution:double_t!
  var AdvertisementArray = [AdvertisementModel]()
  var dcPathButton:DCPathButton!
  let locationManager = CLLocationManager()
  var bluetoothManager = CBCentralManager()
  var beaconRegions = [String: [String: String]]()
  var myView:MainHeaderView!
  
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getlastOrder()
    setupNotification()
    setupCoreLocationService()
    setupBluetoothManager()
    initTCPSessionManager()
    configureDCPathButton()
    getAdvertisementData()
    registerNotification()
    
    navigationController?.navigationBarHidden = false
    tableView.tableFooterView = UIView()
    
    let nibName = UINib(nibName: MainViewCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: MainViewCell.reuseIdentifier())
    let nibName1 = UINib(nibName: WebViewCell.nibName(), bundle: nil)
    tableView.registerNib(nibName1, forCellReuseIdentifier: WebViewCell.reuseIdentifier())
    let nibName2 = UINib(nibName: ActivationCell.nibName(), bundle: nil)
    tableView.registerNib(nibName2, forCellReuseIdentifier: ActivationCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainTVC", owner:self, options:nil)
  }
  
  deinit {
    unregisterNotification()
  }
  
  func getAdvertisementData() {
    ZKJSHTTPSessionManager.sharedInstance().getAdvertisementListWithSuccess({ (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      let dic = responseObject as! NSDictionary
      let advertisement = AdvertisementModel(dic: dic as! [String:AnyObject])
      self.AdvertisementArray.append(advertisement)
      self.tableView.reloadData()
      
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func getlastOrder() {
    ZKJSHTTPSessionManager.sharedInstance().getLatestOrderWithSuccess({(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let lastOrder = responseObject as! NSDictionary
      if let reservation_no = lastOrder["reservation_no"] as? String {
        if reservation_no == "0" {
          StorageManager.sharedInstance().updateLastOrder(nil)
        } else {
          let order = BookOrder(dictionary: responseObject as! NSDictionary)
          StorageManager.sharedInstance().updateLastOrder(order)
        }
        self.tableView.reloadData()
      }
      
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func configureDCPathButton() {
    let image = UIImage(named: "ic_zhong_nor")
    
    dcPathButton = DCPathButton(centerImage: image, highlightedImage: UIImage(named: "ic_zhong_pre"))
    dcPathButton.delegate = self
    view.frame = UIScreen.mainScreen().bounds
    dcPathButton.dcButtonCenter = CGPointMake(view.bounds.width/2, view.bounds.height-40)
    dcPathButton.allowSounds = true
    dcPathButton.allowCenterButtonRotation = true
    dcPathButton.bloomRadius = 90
    let guester = UILongPressGestureRecognizer(target: self, action: "long:")
    guester.minimumPressDuration = 1.5
    dcPathButton.addGestureRecognizer(guester)
    
    let itemButton_1 = DCPathItemButton(image: UIImage(named: "ic_canyin"), highlightedImage: UIImage(named: "ic_canyin"), backgroundImage: UIImage(named: "ic_canyin"), backgroundHighlightedImage: UIImage(named: "ic_canyin"))
    let itemButton_2 = DCPathItemButton(image: UIImage(named: "ic_jiudian"), highlightedImage: UIImage(named: "ic_jiudian"), backgroundImage: UIImage(named: "ic_jiudian"), backgroundHighlightedImage: UIImage(named: "ic_jiudian"))
    let itemButton_3 = DCPathItemButton(image: UIImage(named: "ic_xiuxian"), highlightedImage: UIImage(named: "ic_xiuxian"), backgroundImage: UIImage(named: "ic_xiuxian"), backgroundHighlightedImage: UIImage(named: "ic_xiuxian"))
    dcPathButton.addPathItems([itemButton_1, itemButton_2, itemButton_3])
    self.view.addSubview(dcPathButton)
    
  }
  
  func long(sender:UILongPressGestureRecognizer) {
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
          if let shopPhone = StorageManager.sharedInstance().shopPhoneWithShopID(shopID.stringValue) {
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
          if let shopPhone = StorageManager.sharedInstance().shopPhoneWithShopID(shopID.stringValue) {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(shopPhone)")!)
          }
        }
      }
    }
  }
  //MARK: - DCPathButtonDelegate
  func pathButton(dcPathButton: DCPathButton!, clickItemButtonAtIndex itemButtonIndex: UInt) {
    
    switch itemButtonIndex {
    case(0):
      let vc = RestaurantTVC()
      self.navigationController?.pushViewController(vc, animated: true)
    case(1):
      let vc = FloatingWindowVC()
      vc.view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
      self.addChildViewController(vc)
      self.view.addSubview(vc.view)
    case(2):
      let vc = LeisureTVC()
      self.navigationController?.pushViewController(vc, animated: true)
    default:
      break
    }
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
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
  }
  
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 2
    }
    else {
      
      return AdvertisementArray.count
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 && indexPath.row == 0{
      
      return ActivationCell.height()
    }
    if indexPath.section == 0 && indexPath.row == 1 {
      return MainViewCell.height()
    }
    else {
      if height == nil {
        return 0
      }else {
        return height
      }
      
    }
    
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 265
    }else {
      return 10
    }
    
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 && indexPath.row == 1{
      let cell = tableView.dequeueReusableCellWithIdentifier("MainViewCell", forIndexPath:indexPath) as! MainViewCell
      if let order = StorageManager.sharedInstance().lastOrder() {
        cell.setData(order)
      }
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    }
    if indexPath.section == 0 && indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("ActivationCell", forIndexPath: indexPath) as! ActivationCell
      
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCellWithIdentifier("WebViewCell", forIndexPath:indexPath) as! WebViewCell
      let ad = AdvertisementArray[indexPath.row]
      let url = NSURL(string: ad.url!)
      let request = NSURLRequest(URL: url!)
      cell.webView.loadRequest(request)
      height = CGFloat ( (cell.webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight")! as NSString).floatValue)
      
      return cell
    }
    
    
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
     
      myView = NSBundle.mainBundle().loadNibNamed("MainHeaderView", owner: self, options: nil).first as! MainHeaderView
      myView.leftButton.addTarget(self, action: "leftPage:", forControlEvents: UIControlEvents.TouchUpInside)
      myView.userImageButton.addTarget(self, action: "setInfo:", forControlEvents: UIControlEvents.TouchUpInside)
      myView.choiceCityButton.addTarget(self, action: "choiceCity:", forControlEvents: UIControlEvents.TouchUpInside)
      setupMainViewUI(myView)
      
      //      self.view.addSubview(myView)
      
      return myView
    }else {
      return nil
    }
  }
  
  func choiceCity(sender:UIButton) {
    let vc = CityVC()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func setupMainViewUI(myView:MainHeaderView) {
    let image = JSHStorage.baseInfo().avatarImage
    myView.userImageButton.setImage(image, forState: .Normal)
    if distance == nil {
      return
    }else {
      //定位客户位子 算出距离目的地酒店的距离
      let formatter = MKDistanceFormatter()
      formatter.units = .Metric
      let distanceString = formatter.stringFromDistance(distance)
//      myView.orderStatusLabel.text = "有订单 距离\(String(format: "%.2f", distance/1000))km"
      myView.orderStatusLabel.text = "有订单 距离\(distanceString)"
      myView.userNameLabel.text = JSHStorage.baseInfo().username
    }
    
    
  }
  
  func downloadImage(notification: NSNotification) {
    let userInfo = notification.userInfo as! [String:AnyObject]
    let imageData = userInfo["avtarImage"] as! NSData
    let image = UIImage(data: imageData)
    myView.userImageButton.setImage(image, forState: UIControlState.Normal)
    self.tableView.reloadData()
    
  }
  
  func setInfo(sender:UIButton) {
    let vc = SettingTableViewController(style: .Grouped)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func leftPage(sender:UIButton) {
    sideMenuViewController.presentLeftMenuViewController()
  }
  
  @IBAction func pushToHotel(sender: AnyObject) {
    let vc = HotelPageVC()
    let nav = UINavigationController(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: { () -> Void in
    })
  }
  
  @IBAction func pushToSale(sender: AnyObject) {
    let vc = SalesTBC()
    navigationController?.presentViewController(vc, animated: true, completion: nil)
  }
  
  private func setupNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"downloadImage:",
      name: "DownloadImageNotification", object: nil)
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSmartPanel", name: "UIApplicationDidBecomeActiveNotification", object: nil)
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
  }
  
  private func removeAllMonitoredRegions() {
    for monitoredRegion in locationManager.monitoredRegions {
      let region = monitoredRegion as! CLBeaconRegion
      locationManager.stopMonitoringForRegion(region)
    }
  }
  
  private func setupGPSMonitor() {
    if #available(iOS 9.0, *) {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestLocation()
    } else {
      locationManager.startMonitoringSignificantLocationChanges()
    }
  }
  
  private func initTCPSessionManager() {
    ZKJSTCPSessionManager.sharedInstance().initNetworkCommunicationWithIP(HOST, port: PORT)
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status != CLAuthorizationStatus.AuthorizedAlways {
      //      let alertView = UIAlertController(title: "无法获取位置", message: "我们将为您提供免登记办理入住手续，该项服务需要使用定位功能，需要您前往设置中心打开定位服务", preferredStyle: .Alert)
      //      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
      //      presentViewController(alertView, animated: true, completion: nil)
    }
    
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error while updating location " + error.localizedDescription)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopMonitoringSignificantLocationChanges()
    //获取客户当前的地理位置
    let coordinate = manager.location!.coordinate
    longitude = coordinate.longitude
    latution = coordinate.latitude
    //计算距离
    let currentLocation = CLLocation(latitude: latution, longitude: longitude)
    if let order = StorageManager.sharedInstance().lastOrder() {
      //得到最近一张订单后取订单所带的经纬度
      if let latitude = order.map_latitude,
        let longitude = order.map_longitude {
          let targetLocation = CLLocation(latitude:latitude, longitude:longitude)
          self.distance = currentLocation.distanceFromLocation(targetLocation)
      }
    }
    
    //    let regeoRequest: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
    //    regeoRequest.searchType = AMapSearchType.ReGeocode
    //    regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
    //    regeoRequest.radius = 10000
    //    regeoRequest.requireExtension = true
    //    print("regeoRequest :\(regeoRequest)")
    //    locationSearch.AMapReGoecodeSearch(regeoRequest)
    
    postGPSLocation(coordinate)
  }
  
  private func postGPSLocation(coordinate: CLLocationCoordinate2D) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let traceTime = dateFormatter.stringFromDate(NSDate())
    ZKJSHTTPSessionManager.sharedInstance().postGPSWithLongitude("\(coordinate.longitude)", latitude: "\(coordinate.latitude)", traceTime: traceTime, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
    if region.identifier == "DetermineCurrentRegionState" {
      print("didDetermineState: \(state.rawValue)")
      if state != CLRegionState.Inside {
        StorageManager.sharedInstance().updateLastBeacon(nil)
      }
      
    }
  }
  
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLBeaconRegion {
      didEnterBeaconRegion(region as! CLBeaconRegion)
    }
    
  }
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLBeaconRegion {
      didExitBeaconRegion(region as! CLBeaconRegion)
    }
    
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
  
}

extension MainTVC: IChatManagerDelegate, EMCallManagerDelegate {
  
  // MARK: - Private
  
  func registerNotification() {
    unregisterNotification()
    
    EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
    EaseMob.sharedInstance().callManager.addDelegate(self, delegateQueue: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "callOutWithChatter:", name: KNOTIFICATION_CALL, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "callControllerClose:", name: KNOTIFICATION_CALL_CLOSE, object: nil)
  }
  
  func unregisterNotification() {
    EaseMob.sharedInstance().chatManager.removeDelegate(self)
    EaseMob.sharedInstance().callManager.removeDelegate(self)
  }
  
  func canRecord() -> Bool {
    var bCanRecord = true
    let audioSession = AVAudioSession.sharedInstance()
    if audioSession.respondsToSelector("requestRecordPermission:") {
      audioSession.requestRecordPermission({ (granted: Bool) -> Void in
        bCanRecord = granted
      })
    }
    
    if bCanRecord == false {
      // Show Alert
      showAlertWithTitle(NSLocalizedString("setting.microphoneNoAuthority", comment: "No microphone permissions"), message: NSLocalizedString("setting.microphoneAuthority", comment: "Please open in \"Setting\"-\"Privacy\"-\"Microphone\"."))
    }
    
    return bCanRecord
  }
  
  func callOutWithChatter(notification: NSNotification) {
    if let object = notification.object as? [String: AnyObject] {
      if canRecord() == false {
        return
      }
      
      guard let chatter = object["chatter"] as? String else { return }
      guard let type = object["type"] as? NSNumber else { return }
      let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
      var callSession: EMCallSession? = nil
      switch type.integerValue {
      case EMCallSessionType.eCallSessionTypeAudio.rawValue:
        callSession = EaseMob.sharedInstance().callManager.asyncMakeVoiceCall(chatter, timeout: 50, error: error)
      case EMCallSessionType.eCallSessionTypeVideo.rawValue:
        callSession = EaseMob.sharedInstance().callManager.asyncMakeVideoCall(chatter, timeout: 50, error: error)
        break
      default:
        break
      }
      
      if callSession != nil && error == nil {
        EaseMob.sharedInstance().callManager.removeDelegate(self)
        
        let callVC = CallViewController(session: callSession, isIncoming: false)
        callVC.modalPresentationStyle = .FullScreen
        presentViewController(callVC, animated: true, completion: nil)
      } else if error != nil {
        showAlertWithTitle(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("ok", comment:"OK"))
      }
    }
  }
  
  func callControllerClose(notification: NSNotification) {
    EaseMob.sharedInstance().callManager.addDelegate(self, delegateQueue: nil)
  }
  
  // MARK: - ICallManagerDelegate
  
  func callSessionStatusChanged(callSession: EMCallSession!, changeReason reason: EMCallStatusChangedReason, error: EMError!) {
    if callSession.status == EMCallSessionStatus.eCallSessionStatusConnected {
      var error: EMError? = nil
      repeat {
        if let isShowPicker = NSUserDefaults.standardUserDefaults().objectForKey("isShowPicker") as? NSNumber {
          if isShowPicker.boolValue == true {
            error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
            break;
          }
          
          if canRecord() == false {
            error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
            break;
          }
          
          if callSession.type == EMCallSessionType.eCallSessionTypeVideo &&
            (UIApplication.sharedApplication().applicationState != UIApplicationState.Active || CallViewController.canVideo() == false) {
              error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
              break;
          }
          
          if isShowPicker.boolValue == false {
            EaseMob.sharedInstance().callManager.removeDelegate(self)
            let callVC = CallViewController(session: callSession, isIncoming: true)
            callVC.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            presentViewController(callVC, animated: true, completion: nil)
            if ((navigationController?.topViewController?.isKindOfClass(ChatViewController)) != nil) {
              let chatVC = navigationController?.topViewController as! ChatViewController
              chatVC.isViewDidAppear = false
            }
          }
        }
      } while 1 > 0
      
      if error != nil {
        EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: EMCallStatusChangedReason.eCallReason_Hangup)
      }
    }
  }
}
