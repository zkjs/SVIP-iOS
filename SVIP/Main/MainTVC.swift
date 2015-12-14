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

class MainTVC: UIViewController {

  var localBaseInfo :JSHBaseInfo?
  var order = BookOrder()
  var height:CGFloat!
  var request:NSURLRequest?
  var originHeight:CGFloat!
  var distance:CLLocationDistance!
  var longitude:double_t!
  var latution:double_t!
  var AdvertisementArray = [AdvertisementModel]()
  var dcPathButton:DCPathButton!
  let locationManager = CLLocationManager()
  var bluetoothManager = CBCentralManager()
  var beaconRegions = [String: [String: String]]()
  var myView:HomeHeaderView!
//  var myFooterView: MainFooterView!
  var didMainURLLoad = false
  var activate = true
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Lifecycle
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainTVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getlastOrder()
    setupNotification()
    setupCoreLocationService()
    setupBluetoothManager()
//    initTCPSessionManager()
    getAdvertisementData()
    registerNotification()
    memberActivation()
   
   
    
   // sideMenuViewController.delegate = self
    
    let nibName = UINib(nibName: CustonCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: CustonCell.reuseIdentifier())
   
    let nibName2 = UINib(nibName: ActivationCell.nibName(), bundle: nil)
    tableView.registerNib(nibName2, forCellReuseIdentifier: ActivationCell.reuseIdentifier())
//    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    navigationController?.navigationBarHidden = true
    tableView.reloadData()
    if request != nil {
   
    }
    
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
//    navigationController?.navigationBarHidden = false
    didMainURLLoad = false
  }
  
  deinit {
    unregisterNotification()
  }
  
  func getAdvertisementData() { 
    ZKJSHTTPSessionManager.sharedInstance().getAdvertisementListWithSuccess({ (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      let dic = responseObject as! NSDictionary
      let advertisement = AdvertisementModel(dic: dic as! [String:AnyObject])
      self.AdvertisementArray.append(advertisement)
      let ad = self.AdvertisementArray[0]
      let url = NSURL(string: ad.url!)
       self.request = NSURLRequest(URL: url!)
      
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
          let order = BookOrder(dictionary: responseObject as! [String: AnyObject])
          StorageManager.sharedInstance().updateLastOrder(order)
        }
        self.tableView.reloadData()
      }
    }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func memberActivation() {
    ZKJSHTTPSessionManager.sharedInstance().InvitationCodeActivatedSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.activate = dic["set"] as! Bool
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
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
  
  func choiceCity(sender:UIButton) {
    let vc = CityVC()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func setupMainViewUI(myView:MainHeaderView) {
    let image = JSHStorage.baseInfo().avatarImage
    myView.userImageButton.setImage(image, forState: .Normal)
    myView.userNameLabel.text = JSHStorage.baseInfo().username
    if activate == true {
      myView.gradeLabel.text = "VIP(已激活)"
    }
    
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
//    let userInfo = notification.userInfo as! [String:AnyObject]
//    let imageData = userInfo["avtarImage"] as! NSData
   // let image = UIImage(data: imageData)
   // myView.userImageButton.setImage(image, forState: UIControlState.Normal)
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
    let vc = ComprehensiveVC()
    let transiton = CATransition()
   // transiton.duration = 0.5
    transiton.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transiton.type = "push"
    transiton.subtype = kCATransitionFromLeft
    vc.view.layer.addAnimation(transiton, forKey: nil)
    navigationController?.pushViewController(vc, animated: false)
  }
  
  @IBAction func pushToSale(sender: AnyObject) {
    let vc = SalesTBC()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func setupNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"downloadImage:",
      name: "DownloadImageNotification", object: nil)
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSmartPanel", name: "UIApplicationDidBecomeActiveNotification", object: nil)
  }
  
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MainTVC: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   return 2
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 338
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
      let cell = tableView.dequeueReusableCellWithIdentifier("ActivationCell", forIndexPath: indexPath) as! ActivationCell
      return cell
     
   
      
//      let cell = tableView.dequeueReusableCellWithIdentifier("MainViewCell", forIndexPath:indexPath) as! MainViewCell
//      if let order = StorageManager.sharedInstance().lastOrder() {
//        cell.setData(order)
//      }
//      cell.selectionStyle = UITableViewCellSelectionStyle.None
//      return cell
    
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if indexPath.section == 0 && indexPath.row == 1 {
      let vc = OrderListTVC()
      navigationController?.pushViewController(vc, animated: true)
    }else {
      let vc = InvitationCodeVC()
      vc.type = InvitationCodeVCType.second
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("HomeHeaderView", owner: self, options: nil).first as! HomeHeaderView
//    myView.leftButton.addTarget(self, action: "leftPage:", forControlEvents: UIControlEvents.TouchUpInside)
//    myView.userImageButton.addTarget(self, action: "setInfo:", forControlEvents: UIControlEvents.TouchUpInside)
//    myView.choiceCityButton.addTarget(self, action: "choiceCity:", forControlEvents: UIControlEvents.TouchUpInside)
  //  setupMainViewUI(myView)
    return myView
  }
  
}

// MARK: - UIWebViewDelegate

extension MainTVC: UIWebViewDelegate {
  
//  func webViewDidFinishLoad(webView: UIWebView) {
//    height = CGFloat ( (webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight")! as NSString).floatValue)
//    // 更新Footer高度
//    var frame = myFooterView.frame
//    frame.size.height = height
//    myFooterView.frame = frame
//    tableView.contentInset = UIEdgeInsetsMake(0, 0, height - originHeight,0)
//    tableView.reloadData()
//    didMainURLLoad = true
//  }
//  
//  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//    if(navigationType == UIWebViewNavigationType.Other && didMainURLLoad == true)//判断是否是点击链接
//    {
//      let urlString = request
//      let vc = WebViewVC()
//      vc.url = urlString
//      navigationController?.pushViewController(vc, animated: true)
//      return false;
//    }
//    else{
//    
//      return true
//    }
//   
////    return true
//  }
}

// MARK: - CLLocationManagerDelegate

extension MainTVC: CLLocationManagerDelegate {
  
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
          print(self.distance)
          self.tableView.reloadData()//不加这句话会导致位置距离变为0
      }
    }
    
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
//          sendEnterRegionPacketWithBeacon(beaconRegion)
      }
    }
  }
  
  private func didExitBeaconRegion(region: CLBeaconRegion!) {

  }
  
  private func sendExitRegionPacketWithBeacon(beacon: [String: String]) {
//    let shopID = beacon["shopid"]
//    let locid = beacon["locid"]
//    let uuid = beacon["uuid"]
//    let major = beacon["major"]
//    let minor = beacon["minor"]
//
//    let notification = UILocalNotification()
//    let alertMessage = "Exit \(shopID!) \(locid!) \(uuid!) \(major!) \(minor!)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  private func sendEnterRegionPacketWithBeacon(beacon: [String: String]) {
//    guard let shopID = beacon["shopid"] else { return }
//    guard let locid = beacon["locid"] else { return }
//    guard let locdesc = beacon["locdesc"] else { return }
//    guard let UUID = beacon["uuid"] else { return }
//    guard let major = beacon["major"] else { return }
//    guard let minor = beacon["minor"] else { return }
//
//    let notification = UILocalNotification()
//    let alertMessage = "Enter \(shopID!) \(locid!) \(uuid!) \(major!) \(minor!)"
//    notification.alertBody = alertMessage
//    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
}

// MARK: - ICallManagerDelegate, EMCallManagerDelegate

extension MainTVC: IChatManagerDelegate, EMCallManagerDelegate {
  
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
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func showOrderWithNO(orderNo: String) {
    let alertView = UIAlertController(title: "订单已生成", message: "请处理你的订单", preferredStyle: .Alert)
    let showOrderAction = UIAlertAction(title: "查看", style: .Default, handler: { [unowned self] (action: UIAlertAction) -> Void in
      let storyboard = UIStoryboard(name: "BookingOrderDetail", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderDetailTVC") as! BookingOrderDetailTVC
      vc.reservation_no = orderNo
      self.navigationController?.pushViewController(vc, animated: true)
      })
    let cancelAction = UIAlertAction(title: "忽略", style: .Cancel, handler: nil)
    alertView.addAction(showOrderAction)
    alertView.addAction(cancelAction)
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  func didReceiveCmdMessage(cmdMessage: EMMessage!) {
    if let chatObject = cmdMessage.messageBodies.first?.chatObject as? EMChatCommand {
      if chatObject.cmd == "sureOrder" {
        // 确定或取消订单
        if let orderNo = cmdMessage.ext["orderNo"] as? String {
          self.showOrderWithNO(orderNo)
        }
      }
    }
  }
  
  func didReceiveOfflineCmdMessages(offlineCmdMessages: [AnyObject]!) {
    for cmdMessage in offlineCmdMessages {
      if let cmdMessage = cmdMessage as? EMMessage {
        if let chatObject = cmdMessage.messageBodies.first?.chatObject as? EMChatCommand {
          if chatObject.cmd == "sureOrder" {
            // 确定或取消订单
            if let orderNo = cmdMessage.ext["orderNo"] as? String {
              self.showOrderWithNO(orderNo)
            }
          }
        }
      }
    }
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
        callVC.modalPresentationStyle = .OverFullScreen
        presentViewController(callVC, animated: true, completion: nil)
      } else if error != nil {
        showAlertWithTitle(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("ok", comment:"OK"))
      }
    }
  }
  
  func callControllerClose(notification: NSNotification) {
    EaseMob.sharedInstance().callManager.addDelegate(self, delegateQueue: nil)
  }
  
  func callSessionStatusChanged(callSession: EMCallSession!, changeReason reason: EMCallStatusChangedReason, error: EMError!) {
    if callSession.status == .eCallSessionStatusConnected {
      var error: EMError? = nil
      let isShowPicker = NSUserDefaults.standardUserDefaults().objectForKey("isShowPicker")
      if isShowPicker != nil && isShowPicker!.boolValue == true {
        error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
        EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
        return
      }
      
      if canRecord() == false {
        error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
        EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
        return
      }
      
      if callSession.type == EMCallSessionType.eCallSessionTypeVideo &&
        (UIApplication.sharedApplication().applicationState != UIApplicationState.Active || CallViewController.canVideo() == false) {
          error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
          EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
          return
      }
      
      if isShowPicker == nil || isShowPicker!.boolValue == false {
        EaseMob.sharedInstance().callManager.removeDelegate(self)
        let callVC = CallViewController(session: callSession, isIncoming: true)
        callVC.modalPresentationStyle = .OverFullScreen
        presentViewController(callVC, animated: true, completion: nil)
        if ((navigationController?.topViewController?.isKindOfClass(ChatViewController)) == true) {
          let chatVC = navigationController?.topViewController as! ChatViewController
          chatVC.isViewDidAppear = false
        }
      }
    }
  }
  
}

// MARK: - CBCentralManagerDelegate

extension MainTVC: CBCentralManagerDelegate {
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
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

//// MARK: - RESideMenuDelegate

//extension MainTVC: RESideMenuDelegate {
//  
//  func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
//    if let vc = menuViewController as? LeftMenuVC {
//      vc.setUI()
//    }
//  }
//  
//}

// MARK: - DCPathButtonDelegate

//extension MainTVC: DCPathButtonDelegate {
//  
//  func configureDCPathButton() {
//    let image = UIImage(named: "ic_zhong_nor")
//    dcPathButton = DCPathButton(centerImage: image, highlightedImage: UIImage(named: "ic_zhong_pre"))
//    dcPathButton.delegate = self
//    view.frame = UIScreen.mainScreen().bounds
//    dcPathButton.dcButtonCenter = CGPointMake(view.bounds.width/2, view.bounds.height-30)
//    dcPathButton.allowSounds = true
//    dcPathButton.allowCenterButtonRotation = true
//    dcPathButton.bloomRadius = 90
//    let guester = UILongPressGestureRecognizer(target: self, action: "long:")
//    guester.minimumPressDuration = 1.5
//    dcPathButton.addGestureRecognizer(guester)
//    
//    let itemButton_1 = DCPathItemButton(image: UIImage(named: "ic_canyin"), highlightedImage: UIImage(named: "ic_canyin"), backgroundImage: UIImage(named: "ic_canyin"), backgroundHighlightedImage: UIImage(named: "ic_canyin"))
//    let itemButton_2 = DCPathItemButton(image: UIImage(named: "ic_jiudian"), highlightedImage: UIImage(named: "ic_jiudian"), backgroundImage: UIImage(named: "ic_jiudian"), backgroundHighlightedImage: UIImage(named: "ic_jiudian"))
//    let itemButton_3 = DCPathItemButton(image: UIImage(named: "ic_xiuxian"), highlightedImage: UIImage(named: "ic_xiuxian"), backgroundImage: UIImage(named: "ic_xiuxian"), backgroundHighlightedImage: UIImage(named: "ic_xiuxian"))
//    dcPathButton.addPathItems([itemButton_1, itemButton_2, itemButton_3])
//    view.addSubview(dcPathButton)
//  }
//  
//  func pathButton(dcPathButton: DCPathButton!, clickItemButtonAtIndex itemButtonIndex: UInt) {
//    
//    switch itemButtonIndex {
//    case(0):
//      let vc = RestaurantTVC()
//      navigationController?.pushViewController(vc, animated: true)
//    case(1):
//      let vc = FloatingWindowVC()
//      vc.view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
//      self.view.addSubview(vc.view)
//      self.addChildViewController(vc)
//    case(2):
//      let vc = LeisureTVC()
//      self.navigationController?.pushViewController(vc, animated: true)
//    default:
//      break
//    }
//  }
//}


