//
//  PhoneSettingSecondViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/26.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PhoneSettingSecondViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var okButton: UIButton!
  
  var countTimer: NSTimer?
  let kCountTime = 30
  var count: Int = 30
  
  convenience init() {
    self.init(nibName:"PhoneSettingSecondViewController", bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("CHANGE_MOBILE_PHONE", comment: "")
  }
  
  func refreshCount() {
    if --count == 0 {
      countTimer?.invalidate()
      okButton.enabled = true
      okButton.setTitle(NSLocalizedString("SEND_VERIFIED_CODE", comment: ""), forState: UIControlState.Disabled)
    }else {
      okButton.setTitle("\(count)S", forState: UIControlState.Disabled)
    }
  }
  @IBAction func buttonClick(sender: UIButton) {
    ZKJSHTTPSMSSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phoneTextField.text, callback: { (successed: Bool, error: NSError!) -> Void in
      if successed {
        self.showHint(NSLocalizedString("VERIFIED_CODE_IS_SENT", comment: ""))
      }
    })
    okButton.enabled = false
    count = kCountTime
    countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
  }
  
  //MARK:- UITextField Delegate
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let phoneText = phoneTextField.text
    let codeText = codeTextField.text
    
    if phoneText?.characters.count == 11 && textField == phoneTextField { //phoneTextField输入11位
      if ZKJSTool.validateMobile(phoneText) {
        okButton.enabled = true
      }else {
        showHint(NSLocalizedString("WRONG_MOBILE_PHONE", comment: ""))
      }
    }
    if phoneText?.characters.count < 11 && okButton.titleLabel?.text == NSLocalizedString("SEND_VERIFIED_CODE", comment: "") {
      okButton.enabled = false
      return true
    }
    
    if phoneText?.characters.count == 11 && codeText?.characters.count == 6 {
      ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(codeText, mobilePhoneNumber: phoneText, callback: { (successed: Bool, error: NSError!) -> Void in
        if successed {
          let dictionary = ["phone" : phoneText!]
          ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithParaDic(dictionary, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
            let dic = responseObject as! NSDictionary
            if dic["set"]!.boolValue! {
              self.showHint(NSLocalizedString("MOBILE_PHONE_IS_CHANGED", comment: ""))
              let controllers = self.navigationController!.viewControllers
              let count = controllers.count
              let vc = controllers[count - 3]
              self.navigationController?.popToViewController(vc, animated: true)
            }
            }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
              
          }
        } else {
          self.showHint(NSLocalizedString("WRONG_VERIFIED_CODE", comment: ""))
        }
      })
    }
    
    return true
  }
  
}
