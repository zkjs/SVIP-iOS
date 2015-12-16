//
//  PhoneSecondVC.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class PhoneSecondVC: UIViewController {
  
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var codeButton: UIButton!
  
  var countTimer = NSTimer()
  var count = 0
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PhoneSecondVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "修改手机2/2"
    
    okButton.enabled = false
    okButton.alpha = 0.5
    
    codeButton.enabled = false
    codeButton.alpha = 0.5
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  // MARK: - Timer
  
  func refreshCount() {
    codeButton.setTitle("\(count)S", forState: .Disabled)
    if count-- == 0 {
      countTimer.invalidate()
      codeButton.enabled = true
      codeButton.alpha = 1.0
    }
  }
  
  // MARK: - Button Action
  
  @IBAction func tappedCodeButton(sender: AnyObject) {
    guard let phone = phoneTextField.text else { return }
    if ZKJSTool.validateMobile(phone) {
      // 发送验证码
      ZKJSHTTPSMSSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phone, callback: { (success: Bool, error: NSError!) -> Void in
        if success {
          ZKJSTool.showMsg("验证码已发送")
          self.codeTextField.becomeFirstResponder()
          self.codeButton.enabled = false
          self.codeButton.alpha = 0.5
          self.count = 30
          self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
        }
      })
    } else {
      ZKJSTool.showMsg("手机格式错误")
    }
  }
  
  @IBAction func tappedOKButton(sender: UIButton) {
    guard let phone = phoneTextField.text else { return }
    guard let code = codeTextField.text else { return }
    
    showHUDInView(view, withLoading: "")
    
    ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(code, mobilePhoneNumber: phone) { (success: Bool, error: NSError!) -> Void in
      if success {
        self.navigationController?.popToRootViewControllerAnimated(true)
      } else {
        ZKJSTool.showMsg("验证码不正确")
      }
    }
  }
  
}

// MARK: - UITextField Delegate

extension PhoneSecondVC: UITextFieldDelegate {
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == phoneTextField {
      // 只有当手机号码填全时，才能验证码按钮可按
      if (range.location + string.characters.count >= 11) {
        codeButton.enabled = true
        codeButton.alpha = 1.0
      } else {
        codeButton.enabled = false
        codeButton.alpha = 0.5
      }
      
      if (range.location + string.characters.count <= 11) {
        return true;
      }
    } else if textField == codeTextField {
      // 只有当验证码填全时，才让登录按钮可按
      if (range.location + string.characters.count >= 4) {
        okButton.enabled = true
        okButton.alpha = 1.0
      } else {
        okButton.enabled = false
        okButton.alpha = 0.5
      }
      
      if (range.location + string.characters.count <= 4) {
        return true;
      }
    }
    return false;
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
