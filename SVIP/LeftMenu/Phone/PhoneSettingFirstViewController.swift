//
//  PhoneSettingFirstViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/26.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PhoneSettingFirstViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var phone: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var smsButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  var countTimer: NSTimer?
  let kCountTime = 30
  var count: Int = 30

  convenience init() {
    self.init(nibName:"PhoneSettingFirstViewController", bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("CHANGE_MOBILE_PHONE", comment: "")
    self.titleLabel.text = NSLocalizedString("VERIFIED_YOUR_PHONE", comment: "")
    self.textField.placeholder = NSLocalizedString("VERIFIED_CODE", comment: "")
    self.smsButton.setTitle(NSLocalizedString("SEND_VERIFIED_CODE", comment: ""), forState: UIControlState.Normal)
    phone.text = JSHStorage.baseInfo().phone
  }
  
  func refreshCount() {
    if --count == 0 {
      countTimer?.invalidate()
      smsButton.enabled = true
      smsButton.setTitle(NSLocalizedString("SEND_VERIFIED_CODE", comment: ""), forState: UIControlState.Disabled)
    }else {
      smsButton.setTitle("\(count)S", forState: UIControlState.Disabled)
    }
  }
  @IBAction func buttonClick(sender: UIButton) {
    ZKJSHTTPSMSSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phone.text, callback: { (successed: Bool, error: NSError!) -> Void in
      if successed {
        self.showHint(NSLocalizedString("VERIFIED_CODE_IS_SENT", comment: ""))
      }
    })
    smsButton.enabled = false
    count = kCountTime
    countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
  }
  
  //MARK:- UITextField Delegate
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == self.textField {
      if textField.text?.characters.count == 6 {
        ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(textField.text, mobilePhoneNumber: phone.text, callback: { (successed: Bool, error: NSError!) -> Void in
          if successed {
            self.navigationController?.pushViewController(PhoneSettingSecondViewController(), animated: true)
          }
        })
      }
    }
    
    return true
  }
  
}
