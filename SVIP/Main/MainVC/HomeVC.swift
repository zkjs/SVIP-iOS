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


class HomeVC: UIViewController, CBCentralManagerDelegate, refreshHomeVCDelegate {
  
  let Identifier = "SettingVCCell"
  let locationManager = CLLocationManager()
  
  var delegate:refreshHomeVCDelegate?
  var bluetoothManager = CBCentralManager()
  var privilegeArray = [PrivilegeModel]()
  var floatingVC = FloatingWindowVC()
  var pushInfoArray = [PushInfoModel]()
  var orderArray = [PushInfoModel]()
  var longitude: double_t!
  var latitude: double_t!
  var beaconRegions = [String: [String: String]]()
  var activate =  true
  var compareNumber: NSNumber!
  var urlArray = [String]()
  var homeUrl = String()
  var count = 0
  var countTimer = 0
  var timer = NSTimer!()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  
  let beaconMonitor = BeaconMonitor.sharedMonitor
  
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
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
   
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
    
    let footer = UIView(frame: CGRectMake(0, 0, 100, 40))
    tableView.tableFooterView = footer
    originOffsetY = privilegeButton.frame.origin.y
    print("userID: \(AccountManager.sharedInstance().userID)")
    print("Token: \(AccountManager.sharedInstance().token)")
    
  }
  
  

  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let loginStats = TokenPayload.sharedInstance.isLogin
//    let image = AccountManager.sharedInstance().avatarImage
    let imageURL = AccountManager.sharedInstance().avatarURL
    if loginStats == true {
      //privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
      privilegeButton.sd_setBackgroundImageWithURL(NSURL(string: imageURL), forState: .Normal, placeholderImage: UIImage(named: "logo_white"))
      privilegeButton.addTarget(self, action: "getPrivilege", forControlEvents: UIControlEvents.TouchUpInside)
      privilegeButton.userInteractionEnabled = false
    } else {
      privilegeButton.setBackgroundImage(UIImage(named: "logo_white"), forState: UIControlState.Normal)
      privilegeButton.userInteractionEnabled = false
    }
    
    pushInfoArray.removeAll()
    delegate = self
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    count++
    loadData()
    let islogin = TokenPayload.sharedInstance.isLogin
    if islogin == true {
      memberActivation()
      getAllMessages()
    } else {
      getPushInfoData()
    }
  
 }
  
  func getAllMessages() {
    let city = "长沙"
    ZKJSJavaHTTPSessionManager.sharedInstance().getMessagesWithCity(city.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()), success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      //      print(responseObject)
      if let defaultNotitification = responseObject["defaultNotitification"] as? NSArray {
        self.pushInfoArray.removeAll()
        for dic in defaultNotitification {
          let pushInfo = PushInfoModel(dic: dic as! [String: AnyObject])
          self.pushInfoArray.append(pushInfo)
        }
      }
      if let notificationForOrder = responseObject["notificationForOrder"] as? NSArray {
        self.orderArray.removeAll()
        for dic in notificationForOrder {
          let  order = PushInfoModel(dic: dic as! [String: AnyObject])
          self.orderArray.append(order)
        }
      }
      if let userPrivilege = responseObject["userPrivilege"] as? [[String: AnyObject]] {
        if userPrivilege.count > 0 {
          self.privilegeArray.removeAll()
          for data in userPrivilege {
            let privilege = PrivilegeModel(dic: data)
            self.privilegeArray.append(privilege)
          }
        }
      }
      self.refreshTableView()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  // TableView Scroller Delegate
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if self.urlArray.count <= self.count {
      self.count = 0
    }else {
      self.homeUrl = self.urlArray[self.count]
    }
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = false
  }
  
  
  //refreshHomeVCDelegate
  func refreshHomeVC(set: Bool) {
    //    getPushInfoData()
    self.refreshTableView()
  }
  
  func refreshTableView() {
    tableView.reloadData()
    //    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    //    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
    tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    //    tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 4)), withRowAnimation: .None)
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    privilegeButton.frame.origin.y = originOffsetY - offsetY - 20
  }
  
  //  func scrollViewDidEndScroll(scrollView: UIScrollView) {
  //    let offsetY = scrollView.contentOffset.y
  //    privilegeButton.frame.origin.y = originOffsetY - offsetY - 20
  //  }
  
  
  func loadData() {
    if let imageArray = StorageManager.sharedInstance().homeImage() {
      // 已有缓存
      print("cached \(imageArray)")
      let randomIndex = Int(arc4random_uniform(UInt32(imageArray.count)))
      homeUrl = imageArray[randomIndex]
    } else {
      // 未有缓冲，从服务器上取
      ZKJSJavaHTTPSessionManager.sharedInstance().getHomeImageWithSuccess({ (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
        print("server \(responseObject)")
        if let array = responseObject as? NSArray {
          for dic in array {
            let url = dic["url"] as! String
            self.urlArray.append(url)
          }
          self.homeUrl = self.urlArray[self.count]
          StorageManager.sharedInstance().saveHomeImages(self.urlArray)
          //        self.tableView.reloadData()
          self.refreshTableView()
        }
        }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
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
        //       self.tableView.reloadData()
        self.refreshTableView()
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
        //        self.tableView.reloadData()
        self.refreshTableView()
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  // Member Activate
  func memberActivation() {
    ZKJSHTTPSessionManager.sharedInstance().InvitationCodeActivatedSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if  let dic = responsObject as? NSDictionary {
        if let set = dic["set"] as? Bool {
          self.activate = set
        }
        self.refreshTableView()
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
    return 4
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return min(7, privilegeArray.count)
    } else if section == 2 {
      return orderArray.count
    } else {
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
    } else if indexPath.section == 1 {
      if privilegeArray.count != 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let privilege = privilegeArray[indexPath.row]
        let pushInfo = PushInfoModel()
        pushInfo.iconbaseurl = privilege.privilegeIcon
        pushInfo.title = privilege.privilegeName
        pushInfo.desc = privilege.privilegeDesc
        cell.accessoryView = nil
        cell.setData(pushInfo)
        return cell
      }
    } else if indexPath.section == 2 {
      if orderArray.count != 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let order = self.orderArray[indexPath.row]
        cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
        cell.setData(order)
        return cell
      }
    } else {
      if pushInfoArray.count != 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let pushInfo = self.pushInfoArray[indexPath.row]
        if pushInfo.shopid == "" {
          cell.accessoryView = nil
        } else {
          cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
        }
        cell.setData(pushInfo)
        return cell
      }
    }
    return UITableViewCell()
  }
  
  func activeCode(sender:UIButton) {
    //激活页面
    let vc = InvitationCodeVC()
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  
  func getPrivilege() {
    countTimer = 0
    self.timer.invalidate()
    
    if privilegeArray.count == 0 {
      return
    }
    floatingVC = FloatingWindowVC()
    floatingVC.delegate = self
    floatingVC.privilegeArray = privilegeArray
    self.view.addSubview(floatingVC.view)
    self.addChildViewController(floatingVC)
    
    let image = AccountManager.sharedInstance().avatarImage
    privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
    privilegeButton.userInteractionEnabled = false
  }
  
  func handleSingleTap() {
    let vc = BluetoothDescriptionVC()
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  
    if pushInfoArray.count != 0 {
      if indexPath.section == 2 {
        let vc = OrderListTVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
      }
      if indexPath.section == 3 {
        let pushInfo = pushInfoArray[indexPath.row]
        if pushInfo.shopid == "" {
          //          let vc = WebViewVC()
          //          vc.hidesBottomBarWhenPushed = true
          //          vc.url = "http://www.zkjinshi.com/about_us/about_svip.html"
          //          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          pushToBookVC(pushInfo)
        }
      }
    }
  }
  
  func pushToBookVC(pushinfo: PushInfoModel) {
    if pushinfo.shopid == "" {
      ZKJSTool.showMsg("暂无商家信息")
      return
    }
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
  
  func highLight() {
    countTimer++
    //    let image = AccountManager.sharedInstance().avatarImage
    if self.countTimer % 2 == 0 {
      //      privilegeButton.setBackgroundImage(UIImage(named: "ic_xintequan"), forState: UIControlState.Normal)
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.privilegeButton.alpha = 0.3
      })
    }
    else {
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.privilegeButton.alpha = 1
      })
      //      privilegeButton.setBackgroundImage(image, forState: UIControlState.Normal)
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

    //开始监听beacon
    beaconMonitor.startMonitoring()
    
    
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status != CLAuthorizationStatus.AuthorizedAlways {
      let alertView = UIAlertController(title: "无法获取位置", message: "我们将为您提供免登记办理入住手续，该项服务需要使用定位功能，需要您前往设置中心打开定位服务", preferredStyle: .Alert)
      alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
      presentViewController(alertView, animated: true, completion: nil)
    } else {
      //开始监听beacon
      beaconMonitor.startMonitoring()
    }
  }
  
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
    /*if region.identifier == "DetermineCurrentRegionState" {
      print("didDetermineState: \(state.rawValue)")
      if state != CLRegionState.Inside {
        StorageManager.sharedInstance().updateLastBeacon(nil)
      }
    }*/
  }
  
}





