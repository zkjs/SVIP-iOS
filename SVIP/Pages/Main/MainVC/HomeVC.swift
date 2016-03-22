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
  
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var avatarsImageView: RoundedImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var walletButton: UIButton!
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var moneyButton: UIButton!
  @IBOutlet weak var notifyButton: UIButton!
  @IBOutlet weak var breathLight: BreathLight!
  
  
  var bluetoothManager = CBCentralManager()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  var hideMoney: Bool = true
  var timer: NSTimer?
  
  
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
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginStateChange:", name: KNOTIFICATION_LOGINCHANGE, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "payInfo", name:kPaymentInfoNotification, object: nil)
    
    addGuestures()
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    //payInfo()
    getBalance()
    getOrderListTimer()
    refreshUserInfo()
  }
  
  deinit {
    timer?.invalidate()
    timer = nil
  }

  func payInfo() {
    //付款消息通知
    let vc = PayInfoVC()

    let childView = vc.view

    self.view.addSubview(childView)
    self.addChildViewController(vc)
    vc.didMoveToParentViewController(self)
    childView.frame = self.view.frame


  }
  
  func getOrderListTimer() {
    if timer != nil {
      timer?.invalidate()
      timer = nil
    }
    
    timer = NSTimer.scheduledTimerWithTimeInterval(10, block: { [weak self] () -> () in
        if let strongSelf = self {
          strongSelf.getOrderList()
        }
      }, repeats: true)
    timer!.fire()
  }
  
  func getOrderList() {
    HttpService.sharedInstance.userPaylistInfo(.NotPaid, page: 0) {[weak self] (data,error) -> Void in
      guard let strongSelf = self else { return }
      if let data = data where data.count > 0 {
        if !strongSelf.breathLight.isAnimating {
          strongSelf.breathLight.startAnimation()
        }
        let pay:PaylistmModel = data[0]
        if let createtime:String = AccountManager.sharedInstance().payCreatetime where createtime != pay.createtime {
          strongSelf.showPayInfo(pay)
        }
        
      } else {
        strongSelf.breathLight.stopAnimation()
      }
    }
  }
  
  func showPayInfo(pay:PaylistmModel) {
    let vc = PayInfoVC()
    let childView = vc.view
    vc.payInfo = pay
    self.view.addSubview(childView)
    self.addChildViewController(vc)
    vc.payInfo = pay
    vc.payInfoDismissClosure = { (stopAnimation) -> Void in
      if stopAnimation {
        self.breathLight.stopAnimation()
      }
    }
    AccountManager.sharedInstance().savePayCreatetime(pay.createtime)
    vc.didMoveToParentViewController(self)
    childView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-100, self.view.frame.size.width, self.view.frame.size.height+100)
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
    toggleMoney()
    refreshUserInfo()
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
    let nc = BaseNC(rootViewController: LoginVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }
  

  func didLoginStateChange(notification: NSNotification) {
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
    //gotoSetting()
  }
  
  // 点击钱包打开金额气泡
  @IBAction func walletAction(sender: AnyObject) {
    toggleMoney()
  }
  
  // 点击气泡打开账单列表
  @IBAction func moneyAction(sender: AnyObject) {
    toggleMoney()
    let vc = PayListTVC()
    vc.orderStatus = .Paid
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 点击呼吸灯打开付款请求
  @IBAction func billAction(sender: AnyObject) {
    let vc = PayListTVC()
    vc.orderStatus = .NotPaid
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func gotoSetting() {
    let storyboard = UIStoryboard(name: "MeTVC", bundle: nil)
    let vcMe = storyboard.instantiateViewControllerWithIdentifier("MeTVC") as! MeTVC
    self.navigationController?.pushViewController(vcMe, animated: true)
  }
  
  func addGuestures() {
    
    let tripleTap = UITapGestureRecognizer(target: self, action: "doTripleTap")
    tripleTap.numberOfTapsRequired = 3
    self.view.addGestureRecognizer(tripleTap)
    
  }
  
  // 点击屏幕三次退出登录
  func doTripleTap() {
    HttpService.sharedInstance.deleteToken(nil)
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    let window = UIApplication.sharedApplication().keyWindow
    window?.rootViewController = BaseNC(rootViewController: LoginVC())
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
      BeaconMonitor.sharedInstance.startMonitoring()
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