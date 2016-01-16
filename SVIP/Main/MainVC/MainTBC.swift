//
//  MainTBC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/4.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
  
  var heightDifference:CGFloat!
  var  isUnSelected = false
  var salesVC = SalesVC()
  let vc = FloatingWindowVC()
  let tipView = UIView()
  let maskLayer1 = CAShapeLayer()
  let guideButton1 = UIButton()
  let guideText1 = UIImageView()
  let maskLayer2 = CAShapeLayer()
  let guideButton2 = UIButton()
  let guideText2 = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    registerNotification()
    
    //首页
    let vc1 = HomeVC()
    let nc1 = BaseNC(rootViewController: vc1)
    let image1 = UIImage(named: "ic_shouye_nor")
    vc1.tabBarItem.image = image1
    vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //酒店餐饮休闲
    let vc2 = ComprehensiveVC()
    let nc2 = BaseNC(rootViewController: vc2)
    vc2.tabBarItem.image = UIImage(named: "tab_shangjia")
    vc2.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //服务中心
    salesVC = SalesVC()
    let nc3 = BaseNC(rootViewController: salesVC)
    salesVC.tabBarItem.image = UIImage(named: "ic_xiaoxi_gary")
    salesVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //我的设置
    let storyboard = UIStoryboard(name: "MeTVC", bundle: nil)
    let vc4 = storyboard.instantiateViewControllerWithIdentifier("MeTVC") as! MeTVC
    vc4.tabBarItem.image = UIImage(named: "ic_wo")
    vc4.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    let nc4 = BaseNC(rootViewController: vc4)
    
    viewControllers = [nc1, nc2, nc3, nc4]
    tabBar.tintColor = UIColor.ZKJS_mainColor()
    
    // 检查版本更新
    checkVersion()
    
    // 新手用户使用指南
    if (!(NSUserDefaults.standardUserDefaults().boolForKey("everLaunched"))) {
      NSUserDefaults.standardUserDefaults().setBool(true, forKey:"everLaunched")
      showTipView()
    }
  }
  
  func showTipView() {
    tipView.frame = view.bounds
    let radius: CGFloat = 60.0
    let path = UIBezierPath(roundedRect: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), cornerRadius: 0.0)
    let circlePath = UIBezierPath(roundedRect: CGRectMake(view.frame.size.width-radius-30, 309, radius, radius), cornerRadius: radius)
    path.appendPath(circlePath)
    path.usesEvenOddFillRule = true
    maskLayer1.path = path.CGPath
    maskLayer1.fillRule = kCAFillRuleEvenOdd
    maskLayer1.fillColor = UIColor.blackColor().CGColor
    maskLayer1.opacity = 0.8
    tipView.layer.addSublayer(maskLayer1)
    view.addSubview(tipView)
    
    guideButton1.setImage(UIImage(named: "default_btn_wozhidaola"), forState: .Normal)
    guideButton1.sizeToFit()
    guideButton1.center = CGPointMake(CGRectGetMidX(view.frame), 309+100)
    guideButton1.addTarget(self, action: "nextTipView", forControlEvents: .TouchUpInside)
    view.addSubview(guideButton1)
 
    guideText1.image = UIImage(named: "default_zhijian")
    guideText1.sizeToFit()
    guideText1.center = CGPointMake(CGRectGetMidX(view.frame)-30, 309+10)
    view.addSubview(guideText1)
  }
  
  func nextTipView() {
    maskLayer1.hidden = true
    guideButton1.hidden = true
    guideText1.hidden = true
    
    let radius: CGFloat = 40.0
    let circleX = CGRectGetMidX(view.frame)+CGRectGetWidth(view.frame)/8.0-radius/2.0
    let circleY = CGRectGetHeight(view.frame)-radius-5
    let path = UIBezierPath(roundedRect: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), cornerRadius: 0.0)
    let circlePath = UIBezierPath(roundedRect: CGRectMake(circleX, circleY, radius, radius), cornerRadius: radius)
    path.appendPath(circlePath)
    path.usesEvenOddFillRule = true
    maskLayer2.path = path.CGPath
    maskLayer2.fillRule = kCAFillRuleEvenOdd
    maskLayer2.fillColor = UIColor.blackColor().CGColor
    maskLayer2.opacity = 0.8
    tipView.layer.addSublayer(maskLayer2)
    view.addSubview(tipView)
    
    guideButton2.setImage(UIImage(named: "default_btn_zhaokefu"), forState: .Normal)
    guideButton2.sizeToFit()
    guideButton2.center = CGPointMake(CGRectGetMidX(view.frame), circleY-190)
    guideButton2.addTarget(self, action: "finishTipView", forControlEvents: .TouchUpInside)
    view.addSubview(guideButton2)
    
    guideText2.image = UIImage(named: "default_xiaoxi")
    guideText2.sizeToFit()
    guideText2.center = CGPointMake(circleX-radius/2.0, circleY-80)
    view.addSubview(guideText2)
  }
  
  func finishTipView() {
    tipView.hidden = true
    guideButton2.hidden = true
    guideText2.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
  }
  
  func checkVersion() {
    let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
    let version = NSNumber(longLong: Int64(buildNumber)!)
    ZKJSJavaHTTPSessionManager.sharedInstance().checkVersionWithVersion(version, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let isForceUpgrade = responseObject["isForceUpgrade"] as? NSNumber {
        if let versionNo = responseObject["versionNo"] as? NSNumber {
          if versionNo.longLongValue > version.longLongValue {
            if isForceUpgrade.integerValue == 0 {
              // 提示更新
              let alertController = UIAlertController(title: "升级提示", message: "已有新版本可供升级", preferredStyle: .Alert)
              let upgradeAction = UIAlertAction(title: "升级", style: .Default, handler: { (action: UIAlertAction) -> Void in
                let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/chao-ji-shen-fen/id1018581123?ls=1&mt=8")
                if UIApplication.sharedApplication().canOpenURL(url!) {
                  UIApplication.sharedApplication().openURL(url!)
                }
              })
              alertController.addAction(upgradeAction)
              let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
              alertController.addAction(cancelAction)
              self.presentViewController(alertController, animated: true, completion: nil)
            } else if isForceUpgrade.integerValue == 1 {
              // 强制更新
              let alertController = UIAlertController(title: "升级提示", message: "请您升级到最新版本，以保证软件的正常使用", preferredStyle: .Alert)
              let upgradeAction = UIAlertAction(title: "升级", style: .Default, handler: { (action: UIAlertAction) -> Void in
                let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/chao-ji-shen-fen/id1018581123?ls=1&mt=8")
                if UIApplication.sharedApplication().canOpenURL(url!) {
                  UIApplication.sharedApplication().openURL(url!)
                }
              })
              alertController.addAction(upgradeAction)
              self.presentViewController(alertController, animated: true, completion: nil)
            }
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  deinit {
    unregisterNotification()
  }

}

extension MainTBC: EMCallManagerDelegate {
  
  // MARK: - Private
  
  func registerNotification() {
    unregisterNotification()
    
    EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
    EaseMob.sharedInstance().callManager.addDelegate(self, delegateQueue: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "callOutWithChatter:", name: KNOTIFICATION_CALL, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "callControllerClose:", name: KNOTIFICATION_CALL_CLOSE, object: nil)
  }
  
  func unregisterNotification() {
    EaseMob.sharedInstance().chatManager.removeDelegate(self)
    EaseMob.sharedInstance().callManager.removeDelegate(self)
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func showOrderAlertWithOrderInfo(order: [String: AnyObject]) {
    if let orderno = order["orderNo"] as? String {
      let alertMessage = "您的订单\(orderno)已新增，请查看详情"
      let alertView = UIAlertController(title: "订单新增", message: alertMessage, preferredStyle: .Alert)
      let checkAction = UIAlertAction(title: "查看", style: .Default, handler: { (action: UIAlertAction) -> Void in
        let index = orderno.startIndex.advancedBy(1)
        let type = orderno.substringToIndex(index)
        print(type)
        if type == "H" {
          let storyboard = UIStoryboard(name: "HotelOrderDetailTVC", bundle: nil)
          let vc = storyboard.instantiateViewControllerWithIdentifier("HotelOrderDetailTVC") as! HotelOrderDetailTVC
          vc.reservation_no = orderno
          self.navigationController?.pushViewController(vc, animated: true)
        }
        if type == "O" {
          let storyboard = UIStoryboard(name: "LeisureOrderDetailTVC", bundle: nil)
          let vc = storyboard.instantiateViewControllerWithIdentifier("LeisureOrderDetailTVC") as! LeisureOrderDetailTVC
          vc.reservation_no = orderno
          self.navigationController?.pushViewController(vc, animated: true)
        }
        if type == "K" {
          let storyboard = UIStoryboard(name: "KTVOrderDetailTVC", bundle: nil)
          let vc = storyboard.instantiateViewControllerWithIdentifier("KTVOrderDetailTVC") as! KTVOrderDetailTVC
          vc.reservation_no = orderno
          self.navigationController?.pushViewController(vc, animated: true)
        }
      })
      let cancelAction = UIAlertAction(title: "知道了", style: .Cancel, handler: nil)
      alertView.addAction(cancelAction)
      alertView.addAction(checkAction)
      presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
  func didReceiveCmdMessage(cmdMessage: EMMessage!) {
    if let chatObject = cmdMessage.messageBodies.first?.chatObject as? EMChatCommand {
      if chatObject.cmd == "sureOrder" {
        // 客服发送订单过来
        if let order = cmdMessage.ext as? [String: AnyObject] {
          showOrderAlertWithOrderInfo(order)
        }
      }
    }
  }
  
  func didReceiveOfflineCmdMessages(offlineCmdMessages: [AnyObject]!) {
    for cmdMessage in offlineCmdMessages {
      if let cmdMessage = cmdMessage as? EMMessage {
        if let chatObject = cmdMessage.messageBodies.first?.chatObject as? EMChatCommand {
          if chatObject.cmd == "sureOrder" {
            // 客服发送订单过来
            if let order = cmdMessage.ext as? [String: AnyObject] {
              showOrderAlertWithOrderInfo(order)
            }
          }
        }
      }
    }
  }
  
  func canRecord() -> Bool {
    var bCanRecord = true
    let audioSession = AVAudioSession.sharedInstance()
    if audioSession.respondsToSelector("requestRecordPermission:") {
      audioSession.requestRecordPermission({ (granted: Bool) -> Void in
        bCanRecord = granted
      })
    }
    
    if bCanRecord == false {
      // Show Alert
      showAlertWithTitle(NSLocalizedString("setting.microphoneNoAuthority", comment: "No microphone permissions"), message: NSLocalizedString("setting.microphoneAuthority", comment: "Please open in \"Setting\"-\"Privacy\"-\"Microphone\"."))
    }
    
    return bCanRecord
  }
  
  func callOutWithChatter(notification: NSNotification) {
    if let object = notification.object as? [String: AnyObject] {
      if canRecord() == false {
        return
      }
      
      guard let chatter = object["chatter"] as? String else { return }
      guard let type = object["type"] as? NSNumber else { return }
      let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
      var callSession: EMCallSession? = nil
      switch type.integerValue {
      case EMCallSessionType.eCallSessionTypeAudio.rawValue:
        callSession = EaseMob.sharedInstance().callManager.asyncMakeVoiceCall(chatter, timeout: 50, error: error)
      case EMCallSessionType.eCallSessionTypeVideo.rawValue:
        callSession = EaseMob.sharedInstance().callManager.asyncMakeVideoCall(chatter, timeout: 50, error: error)
        break
      default:
        break
      }
      
      if callSession != nil && error == nil {
        EaseMob.sharedInstance().callManager.removeDelegate(self)
        
        let callVC = CallViewController(session: callSession, isIncoming: false)
        callVC.modalPresentationStyle = .OverFullScreen
        presentViewController(callVC, animated: true, completion: nil)
      } else if error != nil {
        showAlertWithTitle(NSLocalizedString("error", comment: "error"), message: NSLocalizedString("ok", comment:"OK"))
      }
    }
  }
  
  func callControllerClose(notification: NSNotification) {
    EaseMob.sharedInstance().callManager.addDelegate(self, delegateQueue: nil)
  }
  
  // 未读消息数量变化回调
  
  func didUnreadMessagesCountChanged() {
    setupUnreadMessageCount()
  }
  
  func didFinishedReceiveOfflineMessages() {
    setupUnreadMessageCount()
  }
  
  func setupUnreadMessageCount() {
    if let conversations = EaseMob.sharedInstance().chatManager.conversations {
      var unreadCount = 0
      for conversation in conversations {
        if let conversation = conversation as? EMConversation {
          unreadCount += Int(conversation.unreadMessagesCount())
        }
      }
      
      if unreadCount > 0 {
        salesVC.tabBarItem.badgeValue = "\(unreadCount)"
      } else {
        salesVC.tabBarItem.badgeValue = nil
      }
      UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
    }
  }
  
}

extension MainTBC: IChatManagerDelegate {
  
  func callSessionStatusChanged(callSession: EMCallSession!, changeReason reason: EMCallStatusChangedReason, error: EMError!) {
    if callSession.status == .eCallSessionStatusConnected {
      var error: EMError? = nil
      let isShowPicker = NSUserDefaults.standardUserDefaults().objectForKey("isShowPicker")
      if isShowPicker != nil && isShowPicker!.boolValue == true {
        error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
        EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
        return
      }
      
      if canRecord() == false {
        error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
        EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
        return
      }
      
      if callSession.type == EMCallSessionType.eCallSessionTypeVideo &&
        (UIApplication.sharedApplication().applicationState != UIApplicationState.Active || CallViewController.canVideo() == false) {
          error = EMError(code: EMErrorType.InitFailure, andDescription: NSLocalizedString("call.initFailed", comment: "Establish call failure"))
          EaseMob.sharedInstance().callManager.asyncEndCall(callSession.sessionId, reason: .eCallReason_Hangup)
          return
      }
      
      if isShowPicker == nil || isShowPicker!.boolValue == false {
        EaseMob.sharedInstance().callManager.removeDelegate(self)
        let callVC = CallViewController(session: callSession, isIncoming: true)
        callVC.modalPresentationStyle = .OverFullScreen
        presentViewController(callVC, animated: true, completion: nil)
        if ((navigationController?.topViewController?.isKindOfClass(ChatViewController)) == true) {
          let chatVC = navigationController?.topViewController as! ChatViewController
          chatVC.isViewDidAppear = false
        }
      }
    }
  }
  
  // MARK: - IChatManagerDelegate 登录状态变化
  
  func didLoginWithInfo(loginInfo: [NSObject : AnyObject]!, error: EMError!) {
    if error != nil {
      NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
      let messageCenterIndex = 2
      let vc = childViewControllers[messageCenterIndex] as! ConversationListController
      vc.isConnect(false)
    }
  }
  
  func didLoginFromOtherDevice() {
    NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
    // 清理系统缓存
    AccountManager.sharedInstance().clearAccountCache()
    
    // 登出环信
    EaseMob.sharedInstance().chatManager.removeAllConversationsWithDeleteMessages!(true, append2Chat: true)
    let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
    print("登出前环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    EaseMob.sharedInstance().chatManager.logoffWithUnbindDeviceToken(true, error: error)
    print("登出后环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    if error != nil {
      print(error.debugDescription)
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
    }
    
    // 弹出登录框
    let nc = BaseNC(rootViewController: LoginVC())
    let window = UIApplication.sharedApplication().keyWindow
    window?.rootViewController?.presentViewController(nc, animated: true, completion: nil)
    ZKJSTool.showMsg("账号在别处登录，请重新重录。")
  }
  
  func didRemovedFromServer() {
    NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
  }
  
  func didServersChanged() {
    NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
  }
  
  func didAppkeyChanged() {
    NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
  }
  
}
