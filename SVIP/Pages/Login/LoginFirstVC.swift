//
//  LoginFirstVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/29.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class LoginFirstVC: UIViewController {

  @IBOutlet weak var bottomBorder: UILabel!
  @IBOutlet weak var phonetextFiled: UITextField!
  @IBOutlet weak var registerButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let str = NSAttributedString(string: "请输入您的手机号码", attributes: [NSForegroundColorAttributeName:UIColor(hex: "#888888")])
    phonetextFiled.attributedPlaceholder = str
    
    registerButton.hidden = true
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LoginFirstVC", owner:self, options:nil)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.navigationBarHidden = true
    
    stopMonitor()
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  func stopMonitor() {
    BeaconMonitor.sharedInstance.stopMonitoring()
    LocationMonitor.sharedInstance.stopUpdatingLocation()
    LocationMonitor.sharedInstance.stopMonitoringLocation()
  }
    
  @IBAction func register(sender: AnyObject) {
    if !isPhoneValid() {
      return
    }
    self.view.endEditing(true)
    sendVCode(.Register, phone: self.phonetextFiled.text!)
  }


  @IBAction func start(sender: AnyObject) {
    if !isPhoneValid() {
      return
    }
    self.view.endEditing(true)
    sendVCode(.Login, phone: self.phonetextFiled.text!)
  }
  
  private func isPhoneValid() -> Bool {
    guard let  str = self.phonetextFiled.text where !str.isEmpty else {
      self.showHint("请输入手机号")
      return false
    }
    if !ZKJSTool.validateMobile(str) {
      self.showHint("请输入正确的手机号")
      return false
    }
    return true
  }
  
  func sendVCode(type: CodeType, phone:String) {
    showHUDInView(view, withLoading: "")
    if type == CodeType.Login {//登录验证码
        HttpService.sharedInstance.requestSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
          self.hideHUD()
          if let error = error {
            if error.code != 5 {// 未注册用户/不在白名单用户 不跳转
              self.showErrorHint(error, withFontSize: 16)
              self.gotoVCodeVC(.Login)
            } else {
              self.showRegisterAlert()
            }
          } else {
            self.showHint("验证码已发送", withFontSize: 18)
            self.gotoVCodeVC(.Login)
          }
        })
    } else {//注册验证码
        HttpService.sharedInstance.registerSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
          self.hideHUD()
          if let error = error {
            self.showErrorHint(error, withFontSize: 18)
          } else {
            self.showHint("验证码已发送", withFontSize: 18)
            self.gotoVCodeVC(.Register)
          }
        })
    }
  }
  
  func gotoVCodeVC(type:CodeType) {
    let vc = LoginVC()
    vc.phone = self.phonetextFiled.text!
    vc.type = type
    let nv = BaseNC(rootViewController:vc)
    self.navigationController?.presentViewController(nv, animated: true, completion: nil)
  }
  
  func showRegisterAlert() {
    let storyboard = UIStoryboard(name: "RegisterAlertVC", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("RegisterAlertVC")
    vc.modalPresentationStyle = .Custom
    presentViewController(vc, animated: false, completion: nil)
  }

}

extension LoginFirstVC:UITextFieldDelegate {
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField.text == "请输入您的手机号" {
      textField.text = ""
    }
    textField.layer.masksToBounds = true
    textField.layer.cornerRadius = 3.0
    textField.layer.borderWidth = 1.0
    textField.layer.borderColor = UIColor.ZKJS_mainColor().CGColor
    bottomBorder.hidden = true
    return true
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text == "" {
      textField.text = "请输入您的手机号"
    }
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    bottomBorder.hidden = false
    textField.layer.borderWidth = 0
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    bottomBorder.hidden = false
    textField.layer.borderWidth = 0
    textField.resignFirstResponder()
    return true
  }
  
}
