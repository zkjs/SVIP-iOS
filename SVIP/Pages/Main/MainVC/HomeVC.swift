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
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didLoginStateChange(_:)), name: KNOTIFICATION_LOGINCHANGE, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(alertPayInfo(_:)), name:kPaymentInfoNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getOrderList), name: UIApplicationWillEnterForegroundNotification, object: nil)
    
    addGuestures()
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    //payInfo()
    getBalance()
    getOrderList()
    refreshUserInfo()
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
    
    let childView = vc.view
    self.view.addSubview(childView)
    self.addChildViewController(vc)
    vc.didMoveToParentViewController(self)
    childView.frame = self.view.frame

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
    let nc = BaseNC(rootViewController: LoginFirstVC())
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
    getBalance()
    toggleMoney()
  }
  
  // 点击气泡打开账单列表
  @IBAction func moneyAction(sender: AnyObject) {
    toggleMoney()
    /*let vc = PayListTVC()
    vc.orderStatus = .Paid
    self.navigationController?.pushViewController(vc, animated: true)*/
    let billStoryboard = UIStoryboard(name:"BillList",bundle: nil)
    let vc = billStoryboard.instantiateViewControllerWithIdentifier("BillListVC") as! BillListVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 点击呼吸灯打开付款请求
  @IBAction func billAction(sender: AnyObject) {
    self.breathLight.stopAnimation()
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
    
    let tripleTap = UITapGestureRecognizer(target: self, action: #selector(doTripleTap))
    tripleTap.numberOfTapsRequired = 3
    self.view.addGestureRecognizer(tripleTap)
    
  }
  
  // 点击屏幕三次退出登录
  func doTripleTap() {
    HttpService.sharedInstance.deleteToken(nil)
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    let window = UIApplication.sharedApplication().keyWindow
    window?.rootViewController = BaseNC(rootViewController: LoginFirstVC())
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