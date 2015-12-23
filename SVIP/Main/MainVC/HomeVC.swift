//
//  HomeVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/8.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
class HomeVC: UIViewController,CBCentralManagerDelegate,refreshHomeVCDelegate {
  var delegate:refreshHomeVCDelegate?
  let Identifier = "SettingVCCell"
  let titles = ["订单状态","最近浏览","服务精选","酒店精选"]
  let locationManager = CLLocationManager()
  var bluetoothManager = CBCentralManager()
  var privilege = PrivilegeModel()
  var floatingVC = FloatingWindowVC()
  //var pushInfo = PushInfoModel()
  var pushInfoArray = [PushInfoModel]()
  var orderArray = [PushInfoModel]()
  var myView: HomeHeaderView!
  var activate =  true
  var longitude: double_t!
  var latution: double_t!
  var beaconRegions = [String: [String: String]]()
  var nowDate = NSDate()
  var compareNumber: NSNumber!
  var hourLabel = String()
  var sexString = String()//性别
  var urlArray = NSMutableArray()
  var homeUrl = String()
  var count = 0
  var countTimer = 0
  var timer = NSTimer!()
  
  
  @IBOutlet weak var tableView: UITableView!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("HomeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCoreLocationService()
    setupBluetoothManager()
    self.navigationController!.navigationBar.translucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    let nibName = UINib(nibName: HomeCell.nibName(), bundle: nil)
    tableView.registerNib(nibName, forCellReuseIdentifier: HomeCell.reuseIdentifier())
    let NibName = UINib(nibName: OrderCustomCell.nibName(), bundle: nil)
    tableView.registerNib(NibName, forCellReuseIdentifier: OrderCustomCell.reuseIdentifier())
    tableView.showsVerticalScrollIndicator = false
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.pushInfoArray.removeAll()
    delegate = self
    navigationController?.navigationBarHidden = true
    count++
    loadData()
    let islogin = AccountManager.sharedInstance().isLogin()
    if islogin == true {
      memberActivation()
      getlastOrder()
    }
    getPushInfoData()
//    
//    ZKJSJavaHTTPSessionManager.sharedInstance().getPrivilegeWithShopID("120", locID: "6", success: { (task: NSURLSessionDataTask!, responsObjcet: AnyObject!) -> Void in
//      self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
//        target:self,selector:Selector("highLight"),
//        userInfo:nil,repeats:true)
//      if let data = responsObjcet as? [String: AnyObject] {
//        self.privilege = PrivilegeModel(dic: data)
//      }
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//    }


  }
  //TableView Scroller Delegate
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if self.urlArray.count <= self.count {
      self.count = 0
    }else {
      self.homeUrl = self.urlArray[self.count] as! String
    }
     navigationController?.navigationBarHidden = false
  }
  
//  func scrollViewDidScroll(scrollView: UIScrollView) {
//    let color = UIColor.ZKJS_mainColor()
//    let offsetY = scrollView.contentOffset.y
//    if (offsetY > 10) {
//      let alpha = min(1, 1 - ((10 + 64 - offsetY) / 64))
//      self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(alpha))
//      
//    } else {
//      self.navigationController?.navigationBar.lt_setBackgroundColor(color.colorWithAlphaComponent(0))
//    }
//  }
  
  //refreshHomeVCDelegate
  func refreshHomeVC(set: Bool) {
    getPushInfoData()
  }
  
  func  loadData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getHomeImageWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        for dic in array {
          let url = dic["url"] as! String
          self.urlArray .addObject(url)
        }
        self.homeUrl = self.urlArray[self.count] as! String
        self.tableView.reloadData()
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func setupUI() {
    let nowDate = NSDate();
    let hourFormatter = NSDateFormatter();
    hourFormatter.dateFormat = "HH";
    let time = hourFormatter.stringFromDate(nowDate);
    let beacon = StorageManager.sharedInstance().lastBeacon()

    if(time <= "09" && time > "00" ){
      hourLabel = "早上好"
    }
    if(time <= "11" && time > "09" ){
      hourLabel = "上午好"
    }
    if(time <= "12" && time > "11" ){
      hourLabel = "中午好"
    }
    if(time <= "18" && time > "12" ){
      hourLabel = "下午好"
    }
    if(time <= "24" && time > "18" ){
      hourLabel = "晚上好"
    }
    myView.greetLabel.text = hourLabel
     let sex = AccountManager.sharedInstance().sex
      if sex == "0" {
        self.sexString = "先生"
      } else {
        self.sexString  = "女士"
      }
    let loginStats = AccountManager.sharedInstance().isLogin()
    let image = AccountManager.sharedInstance().avatarImage
    if loginStats == false {
      self.myView.loginButton.setTitle("立即登录", forState: UIControlState.Normal)
      self.myView.loginButton.tintColor = UIColor.ZKJS_mainColor()
      self.myView.loginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
      self.myView.dynamicLabel.text = "使用超级身份，享受超凡个性服务"
    }
    if loginStats == true && activate == false {
      myView.usernameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
      self.myView.LocationButton.setBackgroundImage(image, forState: UIControlState.Normal)
      self.myView.activateButton.setTitle("立即激活", forState: UIControlState.Normal)
      self.myView.activateButton.tintColor = UIColor.ZKJS_mainColor()
      self.myView.activateButton.addTarget(self, action: "activated:", forControlEvents: UIControlEvents.TouchUpInside)
      self.myView.dynamicLabel.text = "输入邀请码激活身份，享受超凡个性服务"
    }
    if loginStats == true && activate == true {
      self.myView.LocationButton.setBackgroundImage(image, forState: UIControlState.Normal)
      myView.usernameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
      self.myView.dynamicLabel.text = "使用超级身份，享受超凡个性服务"
    }
    if loginStats == true && activate == true && beacon != nil {
      self.myView.LocationButton.setBackgroundImage(image, forState: UIControlState.Normal)
      myView.usernameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
      self.myView.dynamicLabel.text = "欢迎光临\(beacon!["shopName"])"
    }
    
  }
  
  func login(sender:UIButton) {
    let vc = LoginVC()
    self.presentViewController(vc, animated: true, completion: nil)
 
  }
  
  func activated(sender:UIButton) {
    //激活页面
    let vc = InvitationCodeVC()
    self.presentViewController(vc, animated: true, completion: nil)
    
  }
  
  func getPushInfoData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getPushInfoToUserWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      print(responseObject)
      if let array = responseObject as? NSArray {
        for dic in array {
         let pushInfo = PushInfoModel(dic: dic as! [String: AnyObject])
         self.pushInfoArray.append(pushInfo)
        }
        self.tableView.reloadData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func getlastOrder() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      print(responseObject)
      if let array = responseObject as? NSArray {
        for dic in array {
        let  order = PushInfoModel(dic: dic as! [String: AnyObject])
          self.orderArray.append(order)
        }
        self.tableView.reloadData()
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  // Member Activate
  func memberActivation() {
    ZKJSHTTPSessionManager.sharedInstance().InvitationCodeActivatedSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.activate = dic["set"] as! Bool
      self.setupUI()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  //  func positioningCity() {
  //     let loc = CLLocation(latitude: latution, longitude: longitude)
  //     let geocoder = CLGeocoder()
  //    geocoder.reverseGeocodeLocation(loc) { (array:[CLPlacemark]?, error:NSError?) -> Void in
  //      if array?.count > 0 {
  //        let placemark = array![0]
  //        var city = placemark.locality
  //        if (city == nil) {
  //          city = placemark.administrativeArea
  //        }
  //        self.currentCity = city
  //        self.myView.currentCityLabe.text = city
  //
  //      }
  //    }
  //  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return orderArray.count
    } else {
      return pushInfoArray.count
    }
    
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 338
    } else {
      return 1
    }
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return HomeCell.height()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    if orderArray.count != 0 && indexPath.section == 0 {
      let order = self.orderArray[indexPath.row]
      cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
      cell.setData(order)
    }
    
    if self.pushInfoArray.count != 0  && indexPath.section == 1{
      let pushInfo = self.pushInfoArray[indexPath.row]
      cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
      cell.setData(pushInfo)
    }
    return cell
  }
  
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let backV = UIView()
    backV.frame = CGRectMake(0, 0, view.frame.size.width, 0)
    backV.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    return backV
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      myView = NSBundle.mainBundle().loadNibNamed("HomeHeaderView", owner: self, options: nil).first as! HomeHeaderView
      if urlArray.count != 0 {
        myView.backgroundImage.sd_setImageWithURL(NSURL(string: self.homeUrl), placeholderImage: nil)
      }
      myView.LocationButton.addTarget(self, action: "getPrivilege", forControlEvents: .TouchUpInside)
      myView.backgroundImage.layer.masksToBounds = true
      let animation = CABasicAnimation(keyPath:"transform.scale")
      //动画选项设定
      animation.duration = 8
      animation.repeatCount = HUGE
      animation.autoreverses = true
      animation.fromValue = NSNumber(double: 1.0)
      animation.toValue = NSNumber(double: 1.4)
      myView.backgroundImage.layer.addAnimation(animation, forKey: "scale-layer")
      setupUI()
      return myView
    }
    else {
      let backV = UIView()
      backV.frame = CGRectMake(0, 0, view.frame.size.width, 0)
      backV.backgroundColor = UIColor.whiteColor()
      return backV
    }
    
  }
  
  func getPrivilege() {
    if privilege.privilegeName == nil{
      return
    }
    countTimer = 0
    self.timer.invalidate()
    floatingVC = FloatingWindowVC()
    floatingVC.delegate = self
    floatingVC.privilege = privilege
    self.view.addSubview(floatingVC.view)
    self.addChildViewController(floatingVC)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let pushInfo = pushInfoArray[indexPath.row]
    if pushInfoArray.count != 0 {
      if indexPath.section == 0 {
        let vc = OrderListTVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
      } else {
        if pushInfo.shopid == "" {
          let vc = WebViewVC()
          vc.hidesBottomBarWhenPushed = true
          vc.url = "http://www.zkjinshi.com/about_us/about_svip.html"
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          pushToBookVC(pushInfo.shopid)
        }
      }
    }
  }
  
  func pushToBookVC(shopid:String) {
    let vc = BookVC()
    vc.shopid = NSNumber(integer: Int(shopid)!)
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  
  // MARK: - CBCentralManagerDelegate
  func centralManagerDidUpdateState(central: CBCentralManager) {
    switch central.state {
    case .PoweredOn:
      print(".PoweredOn")
    case .PoweredOff:
      print(".PoweredOff")
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


// MARK: - CLLocationManagerDelegate

extension HomeVC: CLLocationManagerDelegate {
  
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
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status != CLAuthorizationStatus.AuthorizedAlways {
      let alertView = UIAlertController(title: "无法获取位置", message: "我们将为您提供免登记办理入住手续，该项服务需要使用定位功能，需要您前往设置中心打开定位服务", preferredStyle: .Alert)
      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
      presentViewController(alertView, animated: true, completion: nil)
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
  
  private func didEnterBeaconRegion(region: CLBeaconRegion!) {
    let beaconRegions = StorageManager.sharedInstance().beaconRegions()
    print(region)
    if let beaconRegion = beaconRegions[region.identifier] {
      let lastSendDate = NSUserDefaults.standardUserDefaults().objectForKey(region.identifier) as? NSDate
      print(region.identifier + " Last Send Date: \(lastSendDate)" + " Now: \(NSDate())")
      // 如果10分钟内再次触发该区域，则不发推送
      if lastSendDate == nil || NSDate().timeIntervalSinceDate(lastSendDate!) >= 60 * 10 {
        StorageManager.sharedInstance().updateLastBeacon(beaconRegion)
        sendEnterRegionPacketWithBeacon(beaconRegion)
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: region.identifier)
      }
    }
  }
  
  private func didExitBeaconRegion(region: CLBeaconRegion!) {
    
  }
  
  private func sendExitRegionPacketWithBeacon(beacon: [String: String]) {
    
  }
  
  private func sendEnterRegionPacketWithBeacon(beacon: [String: String]) {
    if AccountManager.sharedInstance().isLogin() == false {
      return
    }
    guard let shopID = beacon["shopid"] else { return }
    guard let locid = beacon["locid"] else { return }
    guard let locdesc = beacon["locdesc"] else { return }
    //    guard let UUID = beacon["uuid"] else { return }
    //    guard let major = beacon["major"] else { return }
    //    guard let minor = beacon["minor"] else { return }
    let userID = AccountManager.sharedInstance().userID
    let userName = AccountManager.sharedInstance().userName
    //    let notification = UILocalNotification()
    //    let alertMessage = "Enter \(shopID!) \(locid!) \(uuid!) \(major!) \(minor!)"
    //    notification.alertBody = alertMessage
    //    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    
    let topic = locid
    let extra = ["locdesc": locdesc,
      "locid": locid,
      "shopid": shopID,
      "userid": userID,
      "username": userName]
    let json = ZKJSTool.convertJSONStringFromDictionary(extra)
    let data = json.dataUsingEncoding(NSUTF8StringEncoding)
    let option = YBPublish2Option()
    let sex = AccountManager.sharedInstance().sex
    var gender = "先生"
    if sex == "1" {
      gender = "女士"
    }
    let alert = "\(userName)\(gender) 到达 \(locdesc)"
    let badge = NSNumber(integer: 1)
    let sound = "default"
    let apnOption = YBApnOption(alert: alert, badge: badge, sound: sound, contentAvailable: nil, extra: extra)
    option.apnOption = apnOption
    YunBaService.publish2(topic, data: data, option: option) { (success: Bool, error: NSError!) -> Void in
      if success {
        print("[result] publish2 data(\(json)) to topic(\(topic)) succeed")
      } else {
        print("[result] publish data(\(json)) to topic(\(topic)) failed: \(error), recovery suggestion: \(error.localizedRecoverySuggestion)")
      }
    }
    //位置区域变化通知
    ZKJSJavaHTTPSessionManager.sharedInstance().regionalPositionChangeNoticeWithUserID(userID, locID: locid, shopID: shopID, success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      let set = dic["set"] as! NSNumber
      if set.boolValue == true {
        print("告诉后台成功")
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
    
    if activate == true {
      //根据酒店区域获取用户特权
      
      ZKJSJavaHTTPSessionManager.sharedInstance().getPrivilegeWithShopID(shopID, locID: locid, success: { (task: NSURLSessionDataTask!, responsObjcet: AnyObject!) -> Void in
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
          target:self,selector:Selector("highLight"),
          userInfo:nil,repeats:true)
        if let data = responsObjcet as? [String: AnyObject] {
          self.privilege = PrivilegeModel(dic: data)
        }
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      }
    }
  }
  
  func highLight() {
    countTimer++
    let image = AccountManager.sharedInstance().avatarImage
    if self.countTimer % 2 == 0 {
      self.myView.LocationButton.setBackgroundImage(UIImage(named: "ic_xintequan"), forState: UIControlState.Normal)
    }
    else {
      self.myView.LocationButton.setBackgroundImage(image, forState: UIControlState.Normal)
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
  }
  
  private func setupGPSMonitor() {
    if #available(iOS 9.0, *) {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestLocation()
    } else {
      locationManager.startMonitoringSignificantLocationChanges()
    }
  }
  
  private func removeAllMonitoredRegions() {
    for monitoredRegion in locationManager.monitoredRegions {
      let region = monitoredRegion as! CLBeaconRegion
      locationManager.stopMonitoringForRegion(region)
    }
  }
}



