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
  @IBOutlet weak var homeBGImage: UIImageView!
  
  var bluetoothManager = CBCentralManager()
  var originOffsetY: CGFloat = 0.0
  var bluetoothStats: Bool!
  
  lazy var imgUrl :String = {
    let randomIndex = Int(arc4random_uniform(UInt32(2)))
    return "home_bg_\(randomIndex+1)"
  }()
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("HomeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    LocationStateObserver.sharedInstance.start()
    setupBluetoothManager()
    self.navigationController!.navigationBar.translucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginStateChange:", name: KNOTIFICATION_LOGINCHANGE, object: nil)
    
    self.homeBGImage.image = UIImage(named: imgUrl)
    
    addGuestures()
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
    navigationController?.navigationBar.translucent = true
    
 }
  
  // TableView Scroller Delegate
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.translucent = false
  }
  
  func addGuestures() {
    let singleTap = UITapGestureRecognizer(target: self, action: "doSingleTap")
    singleTap.numberOfTapsRequired = 1
    self.view.addGestureRecognizer(singleTap)
    
    let tripleTap = UITapGestureRecognizer(target: self, action: "doTripleTap")
    tripleTap.numberOfTapsRequired = 3
    self.view.addGestureRecognizer(tripleTap)
    
    singleTap.requireGestureRecognizerToFail(tripleTap)
  }
  
  func doSingleTap() {
    let alertVC = UIAlertController(title: "提示", message: "您无需任何操作即可享受我们的尊贵VIP服务,连续点击屏幕3次退出登录", preferredStyle: .Alert)
    let okButton = UIAlertAction(title: "确认", style: .Cancel, handler: nil)
    alertVC.addAction(okButton)
    self.navigationController?.presentViewController(alertVC, animated: true, completion: nil)
  }
  
  func doTripleTap() {
    HttpService.sharedInstance.deleteToken(nil)
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    if let window = UIApplication.sharedApplication().delegate?.window {
      window!.rootViewController = BaseNC(rootViewController: LoginVC())
    }
  }
  
  
  func login(sender:UIButton) {
    let nc = BaseNC(rootViewController: LoginVC())
    self.presentViewController(nc, animated: true, completion: nil)
  }
  
  
  private func setupBluetoothManager() {
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func didLoginStateChange(notification: NSNotification) {
  }
  
}



// MARK: - CBCentralManagerDelegate
extension HomeVC: CBCentralManagerDelegate {

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
