//
//  LoginVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/1.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import Spring

class LoginVC: UIViewController {
  
  @IBOutlet weak var phoneTextField: DesignableTextField!
  @IBOutlet weak var codeTextField: DesignableTextField!
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var codeButton: UIButton!
  
  var originCenter = CGPointZero
  var count = 0
  var countTimer = NSTimer()
  
  // MARK: - View Lifecycle
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LoginVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)

    setupView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    AccountManager.sharedInstance().clearAccountCache()
    TokenPayload.sharedInstance.clearCacheTokenPayload()
    navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    navigationController?.navigationBarHidden = false
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self);
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  // MARK: - Button Action
  
  @IBAction func confirm(sender: AnyObject) {
    loginAction()
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissSelf()
  }
  
  // MARK: - Private
  private func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func getUserInfo(completionHandler: (() -> Void)?) {
    HttpService.sharedInstance.getUserinfo { (json, error) -> () in
      self.hideHUD()
      if let error = error {
        if let msg = error.userInfo["resDesc"] as? String {
          ZKJSTool.showMsg(msg)
        }
      } else {//登陆成功后再登陆环信
//        self.loginEaseMob()
        completionHandler?()
      }
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
  
  private func loginAction() {
    guard let phone = phoneTextField.text else { return }
    guard let code = codeTextField.text else { return }
    if !isFormValid() {
      return
    }
    
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.loginWithCode(code, phone: phone) { (json, error) -> () in
      if let error = error {
        if error.code == 11 {//还未完善用户资料就跳转到用户资料完善页面
          self.getUserInfo() {
            self.navigationController?.pushViewController(InfoEditVC(), animated: true)
          }
        } else {
          self.hideHUD()
          if let msg = error.userInfo["resDesc"] as? String {
            ZKJSTool.showMsg(msg)
          }
        }
      } else {//登陆成功后获取用户资料
        self.getUserInfo({ () -> Void in
          MobClick.profileSignInWithPUID(TokenPayload.sharedInstance.userID)
          NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
          
          AccountManager.sharedInstance().setDemoAccount(phone == ZKJSConfig.sharedInstance.DEMO_ACCOUNT)
          
          if let window = UIApplication.sharedApplication().delegate?.window {
            window!.rootViewController = BaseNC(rootViewController: HomeVC())
          }
        })
      }
    }
    
  }
  
  private func setupView() {
    let screenSize = UIScreen.mainScreen().bounds
    originCenter = CGPointMake(screenSize.midX, screenSize.midY)
    
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
    
    okButton.enabled = false
    okButton.alpha = 0.5
    
    codeButton.layer.borderWidth = 0.6
    codeButton.layer.borderColor = UIColor(hex: "#C7C7CD").CGColor
    codeButton.backgroundColor = UIColor.whiteColor()
    codeButton.setTitleColor(UIColor(hex: "#C7C7CD"), forState: .Normal)
    codeButton.enabled = false
  }
  

  // MARK: Button Action
  
  @IBAction func tappedCodeButton(sender: UIButton) {
    guard let phone = phoneTextField.text else { return }
    
    if ZKJSTool.validateMobile(phone) {
      self.codeButton.enabled = false
      HttpService.sharedInstance.requestSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
        if let error = error {
          self.codeButton.enabled = true
          if let msg = error.userInfo["resDesc"] as? String {
            ZKJSTool.showMsg(msg)
          }
        } else {
          ZKJSTool.showMsg("验证码已发送")
          self.codeTextField.becomeFirstResponder()
          self.codeButton.alpha = 0.5
          self.count = 30
          self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
        }
      })
    } else {
      ZKJSTool.showMsg("手机格式错误")
    }
  }

  @IBAction func tappedLicense(sender: AnyObject) {
    let vc = WebViewVC()
    vc.url = "http://zkjinshi.com/about_us/use_agree.html"
    navigationController?.pushViewController(vc, animated: true)
  }
  
  // MARK: - Timer
  
  func refreshCount() {
    codeButton.setTitle("\(count)S", forState: .Disabled)
    if count-- == 0 {
      countTimer.invalidate()
      codeButton.enabled = true
      codeButton.alpha = 1.0
      codeButton.setTitle("验证码", forState: .Disabled)
    }
  }
  
  // MARK: Notification
  
  func keyboardWillShow(notification: NSNotification) {
    if view.center == originCenter {
      if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        let center = view.center
        let moveUp = max(0, keyboardSize.height - (CGRectGetHeight(view.frame) - CGRectGetMaxY(codeTextField.frame))) + 90.0
        view.center = CGPointMake(center.x, center.y - moveUp)
      }
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    view.center = originCenter
  }
  
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
  
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
        codeButton.layer.borderColor = UIColor(hex: "#C7C7CD").CGColor
        codeButton.backgroundColor = UIColor.whiteColor()
        codeButton.setTitleColor(UIColor(hex: "#C7C7CD"), forState: .Normal)
        codeButton.enabled = false
      }
      
      if (range.location + string.characters.count <= 11) {
        return true;
      }
    } else if textField == codeTextField {
      // 只有当验证码填全时，才让登录按钮可按
      if (range.location + string.characters.count >= 6) {
        okButton.enabled = true
        okButton.alpha = 1.0
      } else {
        okButton.enabled = false
        okButton.alpha = 0.5
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
        loginAction()
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
  
  @IBAction func register(sender: AnyObject) {
    let vc = RegisterVC()
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}

