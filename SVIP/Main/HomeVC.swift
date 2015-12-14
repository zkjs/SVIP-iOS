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
class HomeVC: UIViewController,CBCentralManagerDelegate{
  var myView:HomeHeaderView!
  var currentCity:String!
  let Identifier = "SettingVCCell"
  let titles = ["订单状态","最近浏览","服务精选","酒店精选"]
  let locationManager = CLLocationManager()
  var activate = true
  var longitude:double_t!
  var latution:double_t!
  var bluetoothManager = CBCentralManager()
  var beaconRegions = [String: [String: String]]()
  var nowDate = NSDate()
  var compareNumber:NSNumber!
  var hourLabel = String()
  var sexString = String()//性别
  @IBOutlet weak var tableView: UITableView!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("HomeVC", owner:self, options:nil)
  }

    override func viewDidLoad() {
        super.viewDidLoad()
      getlastOrder()
      memberActivation()
      setupCoreLocationService()
      setupBluetoothManager()
//      initTCPSessionManager()
      
     

      tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
      let nibName = UINib(nibName: HomeCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: HomeCell.reuseIdentifier())
      let NibName = UINib(nibName: OrderCustomCell.nibName(), bundle: nil)
      tableView.registerNib(NibName, forCellReuseIdentifier: OrderCustomCell.reuseIdentifier())
      //myView.LocationButton.addTarget(self, action: "choiceCity:", forControlEvents: UIControlEvents.TouchUpInside)
      

        // Do any additional setup after loading the view.
     
    }
  
  //定义一个带字符串参数的闭包
  func myClosure(testStr:String)->Void{
    myView.currentCityLabe.text = testStr
  }
  
  func choiceCity(sender:UIButton) {
    let vc = CityVC()
    vc.testClosure = myClosure
    if currentCity != nil {
      vc.city = self.currentCity
    }
    let nav = UINavigationController(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true, completion: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    
    
    //tableView.reloadData()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
   // navigationController?.navigationBarHidden = false
  }
  
  func setupUI() {
    let nowDate = NSDate();
    let hourFormatter = NSDateFormatter();
    hourFormatter.dateFormat = "HH";
    let time = hourFormatter.stringFromDate(nowDate);
    if(time <= "09" || time > "00" ){
      hourLabel = "早上好"
    }
    if(time <= "11" || time > "09" ){
      hourLabel = "上午好"
    }
    if(time <= "12" || time > "11" ){
      hourLabel = "中午好"
    }
    if(time <= "18" || time > "13" ){
      hourLabel = "下午好"
    } else{
      hourLabel = "晚上好"
    }
    myView.greetLabel.text = hourLabel
    if  let int = JSHStorage.baseInfo().sex {
      if int == "0" {
        self.sexString = "女士"
      } else {
        self.sexString  = "先生"
      }
    }
    
    myView.usernameLabel.text =  JSHStorage.baseInfo().username + "  \(self.sexString)"
//    let order = StorageManager.sharedInstance().lastOrder()
//    let beacon = StorageManager.sharedInstance().lastBeacon()
//    
//    let formatter = NSDateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//    //根据日期判断是不是这张订单已过期
//    let dateString = formatter.stringFromDate(nowDate)
//    compareNumber = NSNumber(int: ZKJSTool.compareOneDay(order?.departure_date, withAnotherDay:dateString ))
//    if beacon == nil  && order == nil {
//      self.myView.activateLabel.text = "\(hourLabel)，您没有任何预定"
//      self.myView.connectButton.setTitle("开始预定", forState: UIControlState.Normal)
//    }
//    if beacon == nil && order != nil {
//      self.myView.activateLabel.text = "\(hourLabel), 您有1任何行程"
//      self.myView.connectButton.setTitle("立即查看", forState: UIControlState.Normal)
//    }
//    if beacon != nil && order == nil {
//      self.myView.activateLabel.text = "\(order?.fullname)"
//      self.myView.connectButton.setTitle("开始预定", forState: UIControlState.Normal)
//      self.myView.custonLabel.text = "专属客服为您24小时服务，如影随行"
//    }
//    if beacon != nil && order != nil {
//      self.myView.activateLabel.text = (order?.fullname)! + "欢迎您"
//      self.myView.connectButton.setTitle("立即查看", forState: UIControlState.Normal)
//    }
//    myView.connectButton.addTarget(self, action: "skip:", forControlEvents: UIControlEvents.TouchUpInside)
    
  }
  
  func skip(sender:UIButton) {
    if( sender.titleLabel?.text == "立即查看") {
      let vc = CustomServiceVC()
      vc.view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
      self.addChildViewController(vc)
      self.view.addSubview(vc.view)
     // self.tabBarController?.selectedIndex = 1
//      let vc = OrderListTVC()
//      self.navigationController?.pushViewController(vc, animated: true)
    }
    if( sender.titleLabel?.text == "开始预定") {
      let vc = CustomServiceVC()
      vc.view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
      self.addChildViewController(vc)
      self.view.addSubview(vc.view)
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
  
  // Member Activate
  func memberActivation() {
    ZKJSHTTPSessionManager.sharedInstance().InvitationCodeActivatedSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
      self.activate = dic["set"] as! Bool
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 338
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return HomeCell.height()
  }
  
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    
      let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
     // if let order = StorageManager.sharedInstance().lastOrder() {
       // cell.setData(order)
     // }
      return cell
    
    
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    myView = NSBundle.mainBundle().loadNibNamed("HomeHeaderView", owner: self, options: nil).first as! HomeHeaderView
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
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
   
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
    //positioningCity()
//    //计算距离
//    let currentLocation = CLLocation(latitude: latution, longitude: longitude)
//    if let order = StorageManager.sharedInstance().lastOrder() {
//      //得到最近一张订单后取订单所带的经纬度
//      if let latitude = order.map_latitude,
//        let longitude = order.map_longitude {
//          let targetLocation = CLLocation(latitude:latitude, longitude:longitude)
    
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
    guard let shopID = beacon["shopid"] else { return }
    guard let locid = beacon["locid"] else { return }
    guard let locdesc = beacon["locdesc"] else { return }
    //    guard let UUID = beacon["uuid"] else { return }
    //    guard let major = beacon["major"] else { return }
    //    guard let minor = beacon["minor"] else { return }
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let userName = JSHStorage.baseInfo().username ?? ""
    
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
    let alert = "\(userName) 到达 \(locdesc)"
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



