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
    if let orderNo = order["orderNo"] as? String {
      let alertMessage = "您的订单\(orderNo)已新增，请查看详情"
      let alertView = UIAlertController(title: "订单新增", message: alertMessage, preferredStyle: .Alert)
      let checkAction = UIAlertAction(title: "查看", style: .Default, handler: { (action: UIAlertAction) -> Void in
        let storyboard = UIStoryboard(name: "BookingOrderDetail", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderDetailTVC") as! BookingOrderDetailTVC
        vc.type = .Present
        vc.reservation_no = orderNo
        let nc = BaseNC(rootViewController:vc)
        self.presentViewController(nc, animated: true, completion: nil)
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
