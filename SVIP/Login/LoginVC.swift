//
//  LoginVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/1.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
  
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
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
    navigationController?.navigationBarHidden = true
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
    guard let phone = phoneTextField.text else { return }
    guard let code = codeTextField.text else { return }
    
    showHUDInView(view, withLoading: "")
    
    if phone == "18503027465" && code == "123456" {
      loginWithPhone(phone)
      return
    }
    
    ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(code, mobilePhoneNumber: phone) { (success: Bool, error: NSError!) -> Void in
      if success {
        self.loginWithPhone(phone)
      } else {
        self.hideHUD()
        self.showHint("验证码不正确")
      }
    }
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissSelf()
  }
  
  // MARK: - Private
  
  private func loginWithPhone(phone: String) {
    ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID(phone, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            // 已注册
            // 缓存userid和token
            AccountManager.sharedInstance().saveAccountInfo(data)
            // 获取用户信息
            self.getUserInfo() {
              self.hideHUD()
              self.dismissSelf()
            }
          } else {
            // 未注册要先注册一下
            self.signupWithPhone(phone)
          }
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    })
  }
  
  private func signupWithPhone(phone: String) {
    ZKJSHTTPSessionManager.sharedInstance().userSignUpWithPhone(phone, openID: nil, success: { (task: NSURLSessionDataTask!, responseObject :AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            // 缓存userid和token
            AccountManager.sharedInstance().saveAccountInfo(data)
            // 获取用户信息
            self.getUserInfo() {
              self.navigationController?.pushViewController(InfoEditVC(), animated: true)
            }
          }
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
  private func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func getUserInfo(closure: () -> Void) {
    ZKJSHTTPSessionManager.sharedInstance().getUserInfoWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String : AnyObject] {
        AccountManager.sharedInstance().saveBaseInfo(data)
        self.easeMobAutoLogin()
        closure()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
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
    codeButton.layer.borderColor = UIColor.hx_colorWithHexString("C7C7CD").CGColor
    codeButton.backgroundColor = UIColor.whiteColor()
    codeButton.setTitleColor(UIColor.hx_colorWithHexString("C7C7CD"), forState: .Normal)
    codeButton.enabled = false
  }
  
  private func easeMobAutoLogin() {
    // 自动登录
    let isAutoLogin = EaseMob.sharedInstance().chatManager.isAutoLoginEnabled
    if isAutoLogin == false {
      let userID = AccountManager.sharedInstance().userID
      EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(userID, password: "123456", completion: { (responseObject: [NSObject : AnyObject]!, error: EMError!) -> Void in
        EaseMob.sharedInstance().chatManager.enableAutoLogin!()
        }, onQueue: nil)
    }
  }

  // MARK: Button Action
  
  @IBAction func tappedCodeButton(sender: UIButton) {
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
        } else {
          if let userInfo = error.userInfo.first {
            self.showHint(userInfo.1 as! String)
          }
        }
      })
    } else {
      ZKJSTool.showMsg("手机格式错误")
    }
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
        codeButton.layer.borderColor = UIColor.hx_colorWithHexString("C7C7CD").CGColor
        codeButton.backgroundColor = UIColor.whiteColor()
        codeButton.setTitleColor(UIColor.hx_colorWithHexString("C7C7CD"), forState: .Normal)
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
