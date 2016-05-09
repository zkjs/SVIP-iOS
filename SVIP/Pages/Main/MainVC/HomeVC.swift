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

class HomeVC: UIViewController,UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate,UIAdaptivePresentationControllerDelegate {
  
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var avatarsImageView: RoundedImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var walletButton: UIButton!
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var moneyButton: UIButton!
  @IBOutlet weak var breathLight: BreathLight!
  @IBOutlet weak var logoutView: UIView!
  @IBOutlet weak var monitoringButton: UIButton!
  @IBOutlet weak var shopLogoImageView: UIImageView!
  
  
  var bluetoothManager = CBCentralManager()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  var hideMoney: Bool = true
  let flipAnimationController = FlipAnimationController()
  let swipeInteractionController = SwipeInteractionController()
  var pushMessages  = [PushMessage]()
  let regionData = RegionData.sharedInstance
  
  @IBOutlet weak var btnRegion: UIButton!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("HomeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    
    LocationStateObserver.sharedInstance.start()
    setupBluetoothManager()
    self.navigationController!.navigationBar.translucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertPayInfo:", name:KNOTIFICATION_PAYMENT, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "getOrderList", name: UIApplicationWillEnterForegroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "welcomeInfo:", name:KNOTIFICATION_WELCOME, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLogo:", name:KNOTIFICATION_CHANGELOGO, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLogo:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "welcomeDismissed", name: KNOTIFICATION_WELCOME_DISMISS, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconFound:", name: KNOTIFICATION_BEACON_FOUND, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshBalance", name:KNOTIFICATION_BALANCECHANGE, object: nil)
    
    addGuestures()
    
    //navigationController?.delegate = self
    
    // V2.0版本暂时屏蔽钱包和支付记录(呼吸灯)功能
    //walletButton.hidden = true
    //breathLight.hidden = true
    print(regionData.allRegions);
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    getBalance()
    getOrderList()
    refreshUserInfo()
    updateLogo()
    HttpService.sharedInstance.getUserinfo { (json, error) in
      self.refreshUserInfo()
    }
    refreshBalance()
    updateRegionView()
  }
  
  func refreshBalance() {
    var cash = StorageManager.sharedInstance().curentCash()
    if cash <= 0.001 {
      cash = 999
      StorageManager.sharedInstance().saveCash(cash)
    }
    self.moneyLabel.text = "￥" + cash.format(".2")
  }
  
  
  private func setButtonView() {
    if StorageManager.sharedInstance().settingMonitoring() {
      monitoringButton.setImage(UIImage(named: "btn_notify"), forState: .Normal)
    } else {
      monitoringButton.setImage(UIImage(named: "btn_mute"), forState: .Normal)
    }
  }
  
  
  func welcomeInfo(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let pushInfo = userInfo["welcomeInfo"] as? PushMessage else {
      return
    }
    let vc = PushMessageVC()

    vc.pushInfo = pushInfo

    if let _ = self.presentedViewController {
      print(pushInfo)
      pushMessages.append(pushInfo)
    } else {
      vc.modalPresentationStyle = .OverFullScreen
      self.presentViewController(vc, animated: false, completion: nil)
    }
    
  }
  
  func welcomeDismissed() {
    guard let pushInfo = pushMessages.popLast() else {
      return
    }
    print(pushInfo)
    let vc = PushMessageVC()
    vc.pushInfo = pushInfo
    vc.modalPresentationStyle = .OverFullScreen
    self.presentViewController(vc, animated: false, completion: nil)
  }
  
  func changeLogo(notification: NSNotification) {
    updateLogo()
  }

  func alertPayInfo(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let payInfo = userInfo["payInfo"] as? PaylistmModel else {
      return
    }
    print(userInfo)
    //付款消息通知
    let vc = PayInfoVC()
    vc.payInfo = payInfo
    
    vc.payInfoDismissClosure = { (stopAnimation) -> Void in
      if stopAnimation {
        self.breathLight.stopAnimation()
      }
    }
    AccountManager.sharedInstance().savePayCreatetime(payInfo.createtime)
    
    vc.modalPresentationStyle = .OverFullScreen
    self.presentViewController(vc, animated: false, completion: nil)

  }
  
  func getOrderList() {
    HttpService.sharedInstance.userPaylistInfo(.NotPaid, page: 0) {[weak self] (data,error) -> Void in
      guard let strongSelf = self else { return }
      if let data = data where data.count > 0 {
        let pay:PaylistmModel = data[0]
        if let createtime:String = AccountManager.sharedInstance().payCreatetime where createtime != pay.createtime {
          //if !strongSelf.breathLight.isAnimating {
            strongSelf.breathLight.startAnimation()
          //}
        }
      } else {
        strongSelf.breathLight.stopAnimation()
      }
    }
  }
  
  // TableView Scroller Delegate
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = false
  }
  
  func setupView() {
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    self.lineView.backgroundColor = UIColor(patternImage: UIImage(named: "home_line")!)
    //updateLogo()
    toggleMoney()
    refreshUserInfo()
  }
  
  func updateLogo() {
    if let shopLogo = StorageManager.sharedInstance().cachedShopLogo()
       where shopLogo.validthru.timeIntervalSinceNow > 0 {
      shopLogoImageView.sd_setImageWithURL(NSURL(string: shopLogo.logo.fullImageUrlFitted), placeholderImage: UIImage(named: "shop_logo_default"))
    } else {
      shopLogoImageView.image = UIImage(named: "shop_logo_default")
    }
  }
  
  func refreshUserInfo() {
    self.avatarsImageView.sd_setImageWithURL(NSURL(string: AccountManager.sharedInstance().avatarURL), placeholderImage: UIImage(named: "logo_white"))
    self.nameLabel.text = AccountManager.sharedInstance().userName
  }
  
  // 账户余额
  func getBalance() {
    HttpService.sharedInstance.getBalance { (balance, error) -> Void in
      if error == nil {
        self.moneyLabel.text = (balance / 100).format(".2")
      }
    }
  }
  
  func login(sender:UIButton) {
    let nc = BaseNC(rootViewController: LoginFirstVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  
  // show/hide the money bubble
  func toggleMoney() {
    moneyButton.hidden = hideMoney
    moneyLabel.hidden = hideMoney
    hideMoney = !hideMoney

  }
  
  // 点击头像到账号管理页面
  @IBAction func accountAction(sender: AnyObject) {
    // 产品要求暂时屏蔽该功能 2016-03-21
    gotoSetting()
  }
  
  // 点击钱包打开金额气泡
  @IBAction func walletAction(sender: AnyObject) {
    getBalance()
    toggleMoney()
  }
  
  // 点击气泡打开账单列表
  @IBAction func moneyAction(sender: AnyObject) {
    toggleMoney()
    let billStoryboard = UIStoryboard(name:"BillList",bundle: nil)
    let vc = billStoryboard.instantiateViewControllerWithIdentifier("BillListVC") as! BillListVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 点击呼吸灯打开付款请求
  @IBAction func billAction(sender: AnyObject) {
//    self.breathLight.stopAnimation()
//    let vc = MessageListTVC()
//    self.navigationController?.pushViewController(vc, animated: true)
    let storyBoard = UIStoryboard(name: "PopOverVC", bundle: nil)
    let popOverVC = storyBoard.instantiateViewControllerWithIdentifier("PopOverVC") as! PopOverVC
    popOverVC.delegate = self
    let nav = UINavigationController(rootViewController: popOverVC)
    nav.modalPresentationStyle = UIModalPresentationStyle.Popover
    let popover = nav.popoverPresentationController
    popOverVC.preferredContentSize = CGSizeMake(100,160)
    popover?.backgroundColor = UIColor.whiteColor()
    popover!.delegate = self
    popover!.sourceView = self.view
    popover!.sourceRect = CGRectMake(ScreenSize.SCREEN_WIDTH-44,70,0,0)
    nav.navigationBarHidden = true
    self.presentViewController(nav, animated: true, completion: nil)
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  
  @IBAction func toggleBeaconMonitoring(sender: UIButton) {
    let monitoring = StorageManager.sharedInstance().settingMonitoring()
    if monitoring {// stop monitoring
      let confirmAlert = UIAlertController(title: "提示", message: "确定要关闭身份吗?", preferredStyle: .Alert)
      let confirmAction = UIAlertAction(title: "确定", style: .Default) { (_) in
        BeaconMonitor.sharedInstance.stopMonitoring()
        LocationMonitor.sharedInstance.stopUpdatingLocation()
        LocationMonitor.sharedInstance.stopMonitoringLocation()
        StorageManager.sharedInstance().settingMonitoring(!monitoring)
        self.setButtonView()
      }
      let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (_) in }
      confirmAlert.addAction(confirmAction)
      confirmAlert.addAction(cancelAction)
      presentViewController(confirmAlert, animated: true, completion: nil)
      
    } else { // start monitoring
      BeaconMonitor.sharedInstance.startMonitoring()
      LocationMonitor.sharedInstance.startUpdatingLocation()
      StorageManager.sharedInstance().settingMonitoring(!monitoring)
      setButtonView()
    }
    
  }
  
  func gotoSetting() {
    let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func addGuestures() {
    let multiTap = UITapGestureRecognizer(target: self, action: "doMultipleTap")
    multiTap.numberOfTapsRequired = 6
    self.logoutView.addGestureRecognizer(multiTap)
    
    let tap = UITapGestureRecognizer(target: self, action: "gotoShopDetail")
    view.bringSubviewToFront(shopLogoImageView)
    shopLogoImageView.userInteractionEnabled = true
    shopLogoImageView.addGestureRecognizer(tap)
  }
  
  // 点击屏幕6次退出登录
  func doMultipleTap() {
    HttpService.sharedInstance.deleteToken(nil)
    clearCacheAfterLogout()
    
    if let nav = navigationController {
      nav.viewControllers = [LoginFirstVC()]
    } else if let window = UIApplication.sharedApplication().keyWindow {
      window.rootViewController = BaseNC(rootViewController: LoginFirstVC())
    }
  }
  
  func gotoShopDetail() {
    let storyBoard = UIStoryboard(name: "ShopDetail", bundle: nil)
    let shopVC = storyBoard.instantiateViewControllerWithIdentifier("ShopDetailVC") as! ShopDetailVC

    
    UIView.transitionWithView((self.navigationController?.view)!, duration: 0.8, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
        self.navigationController?.pushViewController(shopVC, animated: false)
      }, completion: nil)
  }
  
}



// MARK: - CBCentralManagerDelegate
extension HomeVC: CBCentralManagerDelegate {
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager) {
    switch central.state {
    case .PoweredOn:
      self.bluetoothStats = true
      if StorageManager.sharedInstance().settingMonitoring() {
        BeaconMonitor.sharedInstance.startMonitoring()
      }
      print(".PoweredOn")
    case .PoweredOff:
      self.bluetoothStats = false
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
  
  func beaconFound(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let beacon = userInfo["beacon"] as? CLBeacon else {
      return
    }
    print(beacon)
    
    if let region = regionData.RegionWithBeacon(beacon) {
      print("========================= enter region")
      print(region)
      regionData.latestRegion = region
      regionData.latestTime = NSDate()
      updateRegionView()
    }
  }
  
  func updateRegionView() {
    regionData.latestRegion = regionData.allRegions?.last!
    if let region = regionData.latestRegion
      where fabs(regionData.latestTime.timeIntervalSinceNow) < 10 * 60 {
      btnRegion.setTitle(region.locdesc, forState: .Normal)
      btnRegion.hidden = false
    } else {
      btnRegion.hidden = true
    }
  }

  @IBAction func regionTapped(sender: UIButton) {
    guard let region = regionData.latestRegion else { return }
    let storyBoard = UIStoryboard(name: "RegionDetail", bundle: nil)
    let vc = storyBoard.instantiateViewControllerWithIdentifier("RegionDetailTVC") as! RegionDetailTVC
    vc.region = region
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: UINavigationControllerDelegate

extension HomeVC: UINavigationControllerDelegate {
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
//    if !fromVC.isKindOfClass(ShopDetailVC) && !toVC.isKindOfClass(ShopDetailVC) {
//      return nil
//    }
    
    if (operation == .Push) {
      swipeInteractionController.wireToViewController(toVC)
    }
    
    flipAnimationController.reverse = operation == .Pop
    return flipAnimationController
  }
  
  func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
  }
}

extension HomeVC: MenuDelegate {
  func selectItem(item: MenuItemType) {
    switch item {
    case .Message:
      let vc = MessageListTVC()
      super.navigationController?.pushViewController(vc, animated: true)
    case .Navigation:
      let storyboard = UIStoryboard(name:"MapInDoors",bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("MapInDoorsVC") as! MapInDoorsVC
      navigationController?.pushViewController(vc, animated: true)
    case .Video:
      let storyboard = UIStoryboard(name:"VideoList",bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("VideoListTVC") as! VideoListTVC
      navigationController?.pushViewController(vc, animated: true)
    case .Switch:
      let storyboard = UIStoryboard(name: "WaiterTipVC", bundle: nil)
      let tipsVC = storyboard.instantiateViewControllerWithIdentifier("WaiterTipVC") as! WaiterTipVC
      self.navigationController?.pushViewController(tipsVC, animated: true)
    default:
      break
    }
  }
}