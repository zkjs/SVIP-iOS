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

class HomeVC: UIViewController {
  let ConstraintBottomHeight:CGFloat = -425
  
  @IBOutlet weak var avatarsImageView: RoundedImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var walletButton: UIButton!
  @IBOutlet weak var breathLight: BreathLight!
  @IBOutlet weak var logoutView: UIView!
  @IBOutlet weak var shopLogoImageView: UIImageView!
  @IBOutlet weak var constraintBottom: NSLayoutConstraint!
  @IBOutlet weak var bottomGestureView: UIView!
  
  var bluetoothManager = CBCentralManager()
  var bluetoothStats: Bool = false
  var hideMoney: Bool = true
  let flipAnimationController = FlipAnimationController()
  let swipeInteractionController = SwipeInteractionController()
  var pushMessages  = [PushMessage]()
  var initialConstraintHeight:CGFloat = 0
  
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
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(alertPayInfo(_:)), name:KNOTIFICATION_PAYMENT, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getOrderList), name: UIApplicationWillEnterForegroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(welcomeInfo(_:)), name:KNOTIFICATION_WELCOME, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeLogo(_:)), name:KNOTIFICATION_CHANGELOGO, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeLogo(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(welcomeDismissed), name: KNOTIFICATION_WELCOME_DISMISS, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ratingOrder(_:)), name: KNOTIFICATION_ORDER, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(welcomeInfo(_:)), name:KNOTIFICATION_ACT_INV, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(welcomeInfo(_:)), name:KNOTIFICATION_ACT_UPDATE, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(activityCancelled(_:)), name:KNOTIFICATION_ACT_CANCEL, object: nil)
    
    addGuestures()
    
    //navigationController?.delegate = self
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getPushMessages), name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    constraintBottom.constant = ConstraintBottomHeight
    initialConstraintHeight = ConstraintBottomHeight
    getOrderList()
    refreshUserInfo()
    updateLogo()
    HttpService.sharedInstance.getUserinfo { (json, error) in
      self.refreshUserInfo()
    }
  }
  
  func getPushMessages() {
    if let msgs = PushMessage.query("userid == '\(TokenPayload.sharedInstance.userID!)' AND read == 0", order: ["timestamp":"DESC"], limit: nil) as? [PushMessage] {
      //pushMessages = msgs
      //print("msgs:\(msgs.count)")
      for m in msgs {
        if !pushMessages.contains(m) {
          pushMessages.append(m)
        }
      }
      
      welcomeDismissed()
    }
  }
  
  func messageExist(m:PushMessage) -> Bool {
    if m.actid == nil {
      return false
    }
    for msg in pushMessages {
      if msg.actid == m.actid {
        return true
      }
    }
    return false
  }
  
  
  func welcomeInfo(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let pushInfo = userInfo["welcomeInfo"] as? PushMessage else {
      return
    }
    let vc = PushMessageVC()
    vc.pushInfo = pushInfo

    if let _ = self.presentedViewController {
      print(pushInfo)
      if !messageExist(pushInfo) {
        pushMessages.append(pushInfo)
      }
    } else {
      vc.modalPresentationStyle = .OverFullScreen
      self.presentViewController(vc, animated: false, completion: nil)
    }
    //getPushMessages()
  }
  
  func welcomeDismissed() {
    guard let pushInfo = pushMessages.last else {
      return
    }
    print(pushInfo)
    
//    if let _ = self.presentedViewController {
//      print("not show")
//    } else {
      pushMessages.popLast()
      pushInfo.read = 1
      pushInfo.save()
      
      let vc = PushMessageVC()
      vc.pushInfo = pushInfo
      vc.modalPresentationStyle = .OverFullScreen
      self.presentViewController(vc, animated: false, completion: nil)
//    }
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
  
  func activityCancelled(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let msg = userInfo["alert"] as? String else {
      return
    }
    let alert = UIAlertController(title: "活动取消", message: msg, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func ratingOrder(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let orderInfo = userInfo["order"] as? PushOrderStatus else {
      return
    }
    let storyboard = UIStoryboard(name:"Service",bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("RatingVC") as! RatingVC
    vc.order = orderInfo
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
    //updateLogo()
    refreshUserInfo()
  }
  
  func updateLogo() {
    if let shopLogo = StorageManager.sharedInstance().cachedShopLogo()
       where shopLogo.validthru.timeIntervalSinceNow > 0 {
      print("change logo:\(shopLogo.logo.fullImageUrlFitted)")
      shopLogoImageView.sd_setImageWithURL(NSURL(string: shopLogo.logo.fullImageUrlFitted), placeholderImage: UIImage(named: "shop_logo_default"))
    } else {
      shopLogoImageView.image = UIImage(named: "shop_logo_default")
    }
  }
  
  func refreshUserInfo() {
    self.avatarsImageView.sd_setImageWithURL(NSURL(string: AccountManager.sharedInstance().avatarURL), placeholderImage: UIImage(named: "logo_white"))
    self.nameLabel.text = AccountManager.sharedInstance().userName
  }
  
  func login(sender:UIButton) {
    let nc = BaseNC(rootViewController: LoginFirstVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  // 点击头像到账号管理页面
  @IBAction func accountAction(sender: AnyObject) {
    gotoSetting()
  }
  
  // 点击钱包打开账单列表
  @IBAction func moneyAction(sender: AnyObject) {
    let billStoryboard = UIStoryboard(name:"BillList",bundle: nil)
    let vc = billStoryboard.instantiateViewControllerWithIdentifier("BillListVC") as! BillListVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 点击呼吸灯打开付款请求
  @IBAction func billAction(sender: AnyObject) {
    self.breathLight.stopAnimation()
    let vc = MessageListTVC()
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 呼叫服务
  @IBAction func serviceAction(sender: AnyObject) {
    let storyboard = UIStoryboard(name:"Service",bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("ServiceListTVC") as! ServiceListTVC
    vc.bluetoothOn = bluetoothStats
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 我的行程
  @IBAction func scheduleAction(sender:AnyObject) {
    let storyboard = UIStoryboard(name:"Activity",bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("MyScheduleTVC") as! MyScheduleTVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 预定
  @IBAction func reserveAction(sender:AnyObject) {
    showHint("coming soon")
  }
  
  func gotoSetting() {
    let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func addGuestures() {
    let multiTap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.doMultipleTap))
    multiTap.numberOfTapsRequired = 6
    self.logoutView.addGestureRecognizer(multiTap)
    
    // tap to show shop detail ViewController
    let tap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.gotoShopDetail))
    //view.bringSubviewToFront(shopLogoImageView)
    shopLogoImageView.userInteractionEnabled = true
    shopLogoImageView.addGestureRecognizer(tap)
    
    // tap to open menu
    let showMenu = UITapGestureRecognizer(target: self, action: #selector(HomeVC.showMenu))
    bottomGestureView.addGestureRecognizer(showMenu)
    
    // drap to open menu
    let pan = UIPanGestureRecognizer(target: self, action: #selector(HomeVC.handlePanGesture(_:)))
    bottomGestureView.addGestureRecognizer(pan)
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
  
  func showMenu() {
    var constant:CGFloat = 0
    if constraintBottom.constant == 0 {
      constant = ConstraintBottomHeight
    } else {
      constant = 0
    }
    snapMenu(constant)
  }
  
  func snapMenu(constraintConstant:CGFloat){
    constraintBottom.constant = constraintConstant
    UIView.animateWithDuration(0.6, delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0,
                               options: UIViewAnimationOptions.CurveEaseInOut,
                               animations: {
                                self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  func handlePanGesture(gestureRecognizer:UIPanGestureRecognizer) {
    let translation:CGPoint = gestureRecognizer.translationInView(view)
    //print(translation)
    switch gestureRecognizer.state {
    case .Began:
      initialConstraintHeight = constraintBottom.constant
      break
    case .Changed:
      constraintBottom.constant = initialConstraintHeight - translation.y
      break
    case .Ended, .Cancelled:
      var fraction = fabs(translation.y / ConstraintBottomHeight)
      fraction = CGFloat(fminf(fmaxf(Float(fraction), 0.0), 1.0))
      if fraction < 0.4 || gestureRecognizer.state == .Cancelled {
        snapMenu(initialConstraintHeight)
      } else {
        if translation.y < 0 {
          snapMenu(0)
        } else {
          snapMenu(initialConstraintHeight == 0 ? ConstraintBottomHeight : 0)
        }
      }
      initialConstraintHeight = 0
      break
    default:
      break
    }
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
}

// MARK: UINavigationControllerDelegate

extension HomeVC: UINavigationControllerDelegate {
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
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