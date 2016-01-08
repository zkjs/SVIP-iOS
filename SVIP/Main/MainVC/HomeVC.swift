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
  let locationManager = CLLocationManager()
  var bluetoothManager = CBCentralManager()
  var privilege = PrivilegeModel()
  var floatingVC = FloatingWindowVC()
  //var pushInfo = PushInfoModel()
  var pushInfoArray = [PushInfoModel]()
  var orderArray = [PushInfoModel]()
  var myView: HomeHeaderView!
  var longitude: double_t!
  var latution: double_t!
  var beaconRegions = [String: [String: String]]()
  var activate =  true
  var compareNumber: NSNumber!
  var urlArray = NSMutableArray()
  var homeUrl = String()
  var count = 0
  var countTimer = 0
  var timer = NSTimer!()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var privilegeButton: UIButton!{
    didSet {
      privilegeButton.layer.masksToBounds = true
      privilegeButton.layer.cornerRadius = 30
    }
  }

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
    let NibName = UINib(nibName: CustonCell.nibName(), bundle: nil)
    tableView.registerNib(NibName, forCellReuseIdentifier: CustonCell.reuseIdentifier())
    tableView.showsVerticalScrollIndicator = false
   
    originOffsetY = privilegeButton.frame.origin.y
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let loginStats = AccountManager.sharedInstance().isLogin()
    let image = AccountManager.sharedInstance().avatarImage
    if loginStats == true {
      privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
      privilegeButton.addTarget(self, action: "getPrivilege", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    self.pushInfoArray.removeAll()
    delegate = self
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    count++
    loadData()
    let islogin = AccountManager.sharedInstance().isLogin()
    if islogin == true {
      memberActivation()
      getlastOrder()
    }
    getPushInfoData()
    
    //根据酒店区域获取用户特权
//    ZKJSJavaHTTPSessionManager.sharedInstance().getPrivilegeWithShopID("120", locID: "6", success: { (task: NSURLSessionDataTask!, responsObjcet: AnyObject!) -> Void in
//              self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
//                target:self,selector:Selector("highLight"),
//                userInfo:nil,repeats:true)
//      self.originOffsetY = self.privilegeButton.frame.origin.y
//      if let data = responsObjcet as? [String: AnyObject] {
//        self.privilege = PrivilegeModel(dic: data)
//        self.privilegeButton.setBackgroundImage(UIImage(named: "ic_xintequan"), forState: UIControlState.Normal)
//       
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
    navigationController?.navigationBar.translucent = false
  }
  
  
  //refreshHomeVCDelegate
  func refreshHomeVC(set: Bool) {
    getPushInfoData()
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    privilegeButton.frame.origin.y = originOffsetY - offsetY - 20
  }

  
  func loadData() {
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
  
  func login(sender:UIButton) {
    let nc = BaseNC(rootViewController: LoginVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  func getPushInfoData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getPushInfoToUserWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
//      print(responseObject)
      if let array = responseObject as? NSArray {
        self.pushInfoArray.removeAll()
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
      if let array = responseObject as? NSArray {
        self.orderArray.removeAll()
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
//      print(responsObject)
      if  let dic = responsObject as? NSDictionary {
        if let set = dic["set"] as? Bool {
          self.activate = set
        }
        self.tableView.reloadData()
      }
     
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
    return 3
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    if section == 1 {
      return orderArray.count
    }
    else {
      return pushInfoArray.count
    }
    
  }
  
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return CustonCell.height()
    } else {
       return HomeCell.height()
    }
   
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
   
    if indexPath.section == 0 {
      let headercell = tableView.dequeueReusableCellWithIdentifier("CustonCell", forIndexPath: indexPath) as! CustonCell
      headercell.selectionStyle = UITableViewCellSelectionStyle.None
      headercell.setData(self.activate,homeUrl: self.homeUrl)
      headercell.activeButton.addTarget(self, action: "activeCode:", forControlEvents: UIControlEvents.TouchUpInside)
      headercell.loginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
      let singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTap")
      headercell.bluetoolView.addGestureRecognizer(singleTap)
//      headercell.PrivilegeButton.addTarget(self, action: "getPrivilege", forControlEvents: .TouchUpInside)
      return headercell
    }
    if orderArray.count != 0 && indexPath.section == 1 {
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      let order = self.orderArray[indexPath.row]
      cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
      cell.setData(order)
      return cell
    }
   else {
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      if pushInfoArray.count != 0 {
        let pushInfo = self.pushInfoArray[indexPath.row]
        cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
        cell.setData(pushInfo)
      }
      return cell
    }
  }
  
  func activeCode(sender:UIButton) {
    //激活页面
    let vc = InvitationCodeVC()
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  
  func getPrivilege() {
    if privilege.privilegeName == nil {
      return
    }
    countTimer = 0
//    self.timer.invalidate()
    floatingVC = FloatingWindowVC()
    floatingVC.delegate = self
    floatingVC.privilege = privilege
    self.view.addSubview(floatingVC.view)
    self.addChildViewController(floatingVC)
    
    let image = AccountManager.sharedInstance().avatarImage
    privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
  }
  
  func handleSingleTap() {
    let vc = BluetoothDescriptionVC()
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
   
    if pushInfoArray.count != 0 {
       let pushInfo = pushInfoArray[indexPath.row]
      if indexPath.section == 1 {
        let vc = OrderListTVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
      }
      if indexPath.section == 2 {
        if pushInfo.shopid == "" {
          let vc = WebViewVC()
          vc.hidesBottomBarWhenPushed = true
          vc.url = "http://www.zkjinshi.com/about_us/about_svip.html"
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          pushToBookVC(pushInfo)
        }
      }
    }
  }

  func pushToBookVC(pushinfo: PushInfoModel) {
    let storyboard = UIStoryboard(name: "BusinessDetailVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BusinessDetailVC") as! BusinessDetailVC
    vc.shopid = NSNumber(integer: Int(pushinfo.shopid)!)
    vc.shopName = pushinfo.shopName
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
      self.bluetoothStats = true
      let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CustonCell
      cell.bluetoolView.hidden = true
      print(".PoweredOn")
    case .PoweredOff:
      self.bluetoothStats = false
      let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CustonCell
      cell.bluetoolView.hidden = false
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
    let userID = AccountManager.sharedInstance().userID
    var userName = AccountManager.sharedInstance().userName
    let sex = AccountManager.sharedInstance().sex
    let topic = locid
    var orderDict = [String: AnyObject]()
    if let order = StorageManager.sharedInstance().lastOrder() {
      orderDict["shopid"] = order.shopid
      orderDict["fullname"] = order.fullname
      orderDict["guest"] = order.guest
      orderDict["rooms"] = order.rooms
      orderDict["room_type"] = order.room_type
      orderDict["room_rate"] = order.room_rate
      orderDict["arrival_date"] = order.arrival_date
      orderDict["departure_date"] = order.departure_date
      orderDict["dayInt"] = order.dayInt
      orderDict["reservation_no"] = order.reservation_no
      orderDict["created"] = order.created
      orderDict["status"] = order.status
    }
    var extra = [String: AnyObject]()
    extra["locdesc"] = locdesc
    extra["locid"] = locid
    extra["shopid"] = shopID
    extra["userid"] = userID
    extra["username"] = userName
    extra["sex"] = sex
    extra["order"] = orderDict
    let json = ZKJSTool.convertJSONStringFromDictionary(extra)
    let data = json.dataUsingEncoding(NSUTF8StringEncoding)
    let option = YBPublish2Option()
    var gender = "先生"
    if sex == "0" {
      gender = "女士"
    }
    if userName.isEmpty {
      userName = "游客"
    }
    let alert = "\(userName)\(gender) 到达 \(locdesc)"
    let badge = NSNumber(integer: 1)
    let sound = "default"
//    var avatarBase64 = ""
//    if let avatar = AccountManager.sharedInstance().avatarImage {
//      var avatarData = UIImageJPEGRepresentation(avatar, 1.0)!
//      var i = 0
//      while avatarData.length / 1024 > 30 {
//        let persent = CGFloat(100 - i++) / 100.0
//        avatarData = UIImageJPEGRepresentation(avatar, persent)!
//      }
//      avatarBase64 = avatarData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//    }
//    let avatarURL = AccountManager.sharedInstance().avatarURL
    let apnDict = ["aps": ["alert": ["body": alert, "title": "到店通知"], "badge": badge, "sound": sound, "category": "arrivalInfo"], "extra": extra]
    print(apnDict)
    let apnOption = YBApnOption(apnDict: apnDict as [NSObject : AnyObject])
    option.apnOption = apnOption
    YunBaService.publish2(topic, data: data, option: option) { (success: Bool, error: NSError!) -> Void in
      if success {
        print("[result] publish2 data(\(json)) to topic(\(topic)) succeed")
      } else {
        print("[result] publish data(\(json)) to topic(\(topic)) failed: \(error), recovery suggestion: \(error.localizedRecoverySuggestion)")
      }
    }
    if activate == true {
      //根据酒店区域获取用户特权
      ZKJSJavaHTTPSessionManager.sharedInstance().getPrivilegeWithShopID(shopID, locID: locid, success: { (task: NSURLSessionDataTask!, responsObjcet: AnyObject!) -> Void in
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
//          target:self,selector:Selector("highLight"),
//          userInfo:nil,repeats:true)
        if let data = responsObjcet as? [String: AnyObject] {
          self.privilege = PrivilegeModel(dic: data)
          self.privilegeButton.setBackgroundImage(UIImage(named: "ic_xintequan"), forState: UIControlState.Normal)
        }
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      }
    }
    //位置区域变化通知
    ZKJSJavaHTTPSessionManager.sharedInstance().regionalPositionChangeNoticeWithUserID(userID, locID: locid, shopID: shopID, success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if let data = responsObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            print("告诉后台成功")
          }
        }
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  func highLight() {
    countTimer++
    let image = AccountManager.sharedInstance().avatarImage
    if self.countTimer % 2 == 0 {
      privilegeButton.setBackgroundImage(UIImage(named: "ic_xintequan"), forState: UIControlState.Normal)
    }
    else {
      privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
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



