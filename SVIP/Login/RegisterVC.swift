//
//  RegisterVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

  @IBOutlet weak var codeButton: UIButton! {
    didSet {
      codeButton.layer.borderWidth = 1
      codeButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
  }
  @IBOutlet weak var codeTextField: DesignableTextField!
  @IBOutlet weak var phoneTextField: DesignableTextField!
  @IBOutlet weak var registerButton: UIButton!
  
  var count = 0
  var countTimer = NSTimer()
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "注册"
      let image = UIImage(named: "ic_fanhui_orange")
      let item = UIBarButtonItem(image: image, style:.Done, target: self, action: "backToLoginVC:")
      self.navigationController?.navigationItem.leftBarButtonItem = item
      
      setupView()

    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("RegisterVC", owner:self, options:nil)
  }
  
  func setupView() {
    let phoneIV = UIImageView(image: UIImage(named: "ic_yonghu"))
    phoneIV.frame = CGRectMake(0.0, 0.0, phoneIV.frame.size.width + 10.0, phoneIV.frame.size.height)
    phoneIV.contentMode = .Center
    phoneTextField.leftViewMode = .Always
    phoneTextField.leftView = phoneIV
    
    let codeIV = UIImageView(image: UIImage(named: "ic_mima"))
    codeIV.frame = CGRectMake(0.0, 0.0, codeIV.frame.size.width + 10.0, phoneIV.frame.size.height)
    codeIV.contentMode = .Center
    codeTextField.leftViewMode = .Always
    codeTextField.leftView = codeIV
  }

  @IBAction func sendCode(sender: AnyObject) {
    guard let phone = phoneTextField.text else { return }
    
    if ZKJSTool.validateMobile(phone) {
      ZKJSTool.showMsg("验证码已发送")
      HttpService.sharedInstance.registerSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
        self.codeTextField.becomeFirstResponder()
        self.codeButton.enabled = false
        self.codeButton.alpha = 0.5
        self.count = 30
        self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
        if let json = json {
          print(json)
        }
      })
    }
    
  }
  
  func refreshCount() {
    codeButton.setTitle("\(count)S", forState: .Disabled)
    if count-- == 0 {
      countTimer.invalidate()
      codeButton.enabled = true
      codeButton.alpha = 1.0
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    view.endEditing(true)
  }

  
  func backToLoginVC(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
    
  @IBAction func register(sender: AnyObject) {
    if isFormValid() {
      registerAction()
    }
    
  }
  
  private func isFormValid() -> Bool {
    guard let phone = phoneTextField.text else { return false}
    guard let code = codeTextField.text else { return false}
    if phone.isEmpty {
      phoneTextField.animation = "shake"
      phoneTextField.animate()
      return false
    }
    if code.isEmpty {
      codeTextField.animation = "shake"
      codeTextField.animate()
      return false
    }
    return true
  }
  
  private func registerAction() {
    guard let phone = phoneTextField.text else { return }
    guard let code = codeTextField.text else { return }
    if !isFormValid() {
      return
    }
    
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.registerWithPhoneNumber(phone, code: code) { (json, error) -> () in
      self.hideHUD()
      if let error = error {
        if let msg = error.userInfo["resDesc"] as? String {
          ZKJSTool.showMsg(msg)
        }
      } else {
        let vc = InfoEditVC()
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
    
  }

}

extension RegisterVC:UITextFieldDelegate {
  func textFieldDidEndEditing(textField: UITextField) {
    textField.resignFirstResponder()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == phoneTextField {
      // 只有当手机号码填全时，才能验证码按钮可按
      if (range.location + string.characters.count >= 11) {
        codeButton.layer.borderWidth = 0.0
        codeButton.layer.borderColor = UIColor.clearColor().CGColor
        codeButton.backgroundColor = UIColor.ZKJS_mainColor()
        codeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        codeButton.enabled = true
      } else {
        codeButton.layer.borderWidth = 0.6
        codeButton.layer.borderColor = UIColor(hexString: "C7C7CD").CGColor
        codeButton.backgroundColor = UIColor.whiteColor()
        codeButton.setTitleColor(UIColor(hexString: "C7C7CD"), forState: .Normal)
        codeButton.enabled = false
      }
      
      if (range.location + string.characters.count <= 11) {
        return true;
      }
    } else if textField == codeTextField {
      // 只有当验证码填全时，才让注册按钮可按
      if (range.location + string.characters.count >= 6) {
        registerButton.enabled = true
        registerButton.alpha = 1.0
      } else {
        registerButton.enabled = false
        registerButton.alpha = 0.5
      }
      
      if (range.location + string.characters.count <= 6) {
        return true;
      }
    }
    return false;
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == codeTextField {
      if isFormValid() {
        textField.resignFirstResponder()
        registerAction()
      }
    }
    return true
  }
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    textField.layer.masksToBounds = true
    textField.layer.cornerRadius = 3.0
    textField.layer.borderWidth = 1.0
    textField.layer.borderColor = UIColor.ZKJS_mainColor().CGColor
    return true
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    textField.layer.borderWidth = 0
    return true
  }
  
}


