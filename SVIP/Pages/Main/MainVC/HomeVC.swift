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
  let ConstraintBottomHeight:CGFloat = -360
  
  @IBOutlet weak var avatarsImageView: RoundedImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var walletButton: UIButton!
  @IBOutlet weak var breathLight: BreathLight!
  @IBOutlet weak var logoutView: UIView!
  @IBOutlet weak var shopLogoImageView: UIImageView!
  @IBOutlet weak var constraintBottom: NSLayoutConstraint!
  @IBOutlet weak var bottomGestureView: UIView!
  
  var bluetoothManager = CBCentralManager()
  var bluetoothStats: Bool!
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
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertPayInfo:", name:KNOTIFICATION_PAYMENT, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "getOrderList", name: UIApplicationWillEnterForegroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "welcomeInfo:", name:KNOTIFICATION_WELCOME, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLogo:", name:KNOTIFICATION_CHANGELOGO, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLogo:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "welcomeDismissed", name: KNOTIFICATION_WELCOME_DISMISS, object: nil)
    
    addGuestures()
    
    //navigationController?.delegate = self
    
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
  
  
  func gotoSetting() {
    let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func addGuestures() {
    let multiTap = UITapGestureRecognizer(target: self, action: "doMultipleTap")
    multiTap.numberOfTapsRequired = 6
    self.logoutView.addGestureRecognizer(multiTap)
    
    // tap to show shop detail ViewController
    let tap = UITapGestureRecognizer(target: self, action: "gotoShopDetail")
    //view.bringSubviewToFront(shopLogoImageView)
    shopLogoImageView.userInteractionEnabled = true
    shopLogoImageView.addGestureRecognizer(tap)
    
    // tap to open menu
    let showMenu = UITapGestureRecognizer(target: self, action: "showMenu")
    bottomGestureView.addGestureRecognizer(showMenu)
    
    // drap to open menu
    let pan = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
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
      navigationController?.popViewControllerAnimated(true)
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
        snapMenu(initialConstraintHeight == 0 ? ConstraintBottomHeight : 0)
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