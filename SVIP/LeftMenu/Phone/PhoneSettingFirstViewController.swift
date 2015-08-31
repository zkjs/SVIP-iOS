//
//  PhoneSettingFirstViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/26.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PhoneSettingFirstViewController: UIViewController {
  @IBOutlet weak var phone: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var smsButton: UIButton!
  
  var countTimer: NSTimer?
  let kCountTime = 30
  var count: Int = 30

  convenience init() {
    self.init(nibName:"PhoneSettingFirstViewController", bundle: nil)
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "修改手机"
    phone.text = JSHStorage.baseInfo().phone
  }
  
  func refreshCount() {
    if --count == 0 {
      countTimer?.invalidate()
      smsButton.enabled = true
      smsButton.setTitle("发送验证码", forState: UIControlState.Disabled)
    }else {
      smsButton.setTitle("\(count)S", forState: UIControlState.Disabled)
    }
  }
  @IBAction func buttonClick(sender: UIButton) {
    ZKJSHTTPSMSSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phone.text, callback: { (successed: Bool, error: NSError!) -> Void in
      if successed {
        ZKJSTool.showMsg("验证码已发送")
      }
    })
    smsButton.enabled = false
    count = kCountTime
    countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
  }
  
  //MARK:- UITextField Delegate
  func textFieldDidChanged(aNotification: NSNotification) {
    let text = textField.text as NSString
    if text.length == 6 {
      ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(textField.text, mobilePhoneNumber: phone.text, callback: { (successed: Bool, error: NSError!) -> Void in
        if successed {
          self.navigationController?.pushViewController(PhoneSettingSecondViewController(), animated: true)
        }
      })
    }
  }
}
