//
//  LoginVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/1.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
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
    nextStep()
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissSelf()
  }
  
  // MARK: - Private
  //TODO: 需要调用老的api登陆获取老的token供其他api调用
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
        self.hideHUD()
        self.showHint("服务器返回数据异常")
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
        self.hideHUD()
        self.showHint("服务器返回数据异常")
    })
  }
  
  private func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func getUserInfo(completionHandler: () -> Void) {
//    ZKJSHTTPSessionManager.sharedInstance().getUserInfoWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//      print(responseObject)
//      if let data = responseObject as? [String : AnyObject] {
////        AccountManager.sharedInstance().saveBaseInfo(data)
//        self.loginEaseMob()
//        closure()
//      }
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        self.hideHUD()
//        self.showHint("服务器返回数据异常")
//    }
    HttpService.sharedInstance.getUserinfo { (json, error) -> () in
      if let _ = error {
        
      } else {
        self.loginEaseMob()
        completionHandler()
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
  
  private func nextStep() {
    guard let phone = phoneTextField.text else { return }
    guard let code = codeTextField.text else { return }
    if !isFormValid() {
      return
    }
    
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.loginWithCode(code, phone: phone) { (json, error) -> () in
      if let _ = error {
      } else {
        //self.loginWithPhone(phone)
        self.getUserInfo({ () -> Void in
          //TODO: 暂时注释下面2行代码,代码放到旧api中回调，待旧api完全切换过来后取消注释
          /*self.hideHUD()
          self.dismissSelf()
          */
          MobClick.profileSignInWithPUID(TokenPayload.sharedInstance.userID)
        })
      }
      //self.dismissSelf()
      //self.hideHUD()
    }
    //需要调用老的api登陆获取老的token供其他api调用
    self.loginWithPhone(phone)
    
//    if phone == "18503027465" && code == "123456" {
//      loginWithPhone(phone)
//      return
//    }
//    
//    ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(code, mobilePhoneNumber: phone) { (success: Bool, error: NSError!) -> Void in
//      if success {
//        self.loginWithPhone(phone)
//      } else {
//        self.hideHUD()
//        self.showHint("验证码不正确")
//      }
//    }
  }
  
  func convertStringToDictionary(text: String) -> JSON? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
      do {
        let js = JSON(data: data)
        print(js)
        return js
        
      }
    }
    return nil
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
    codeButton.layer.borderColor = UIColor(hexString: "C7C7CD").CGColor
    codeButton.backgroundColor = UIColor.whiteColor()
    codeButton.setTitleColor(UIColor(hexString: "C7C7CD"), forState: .Normal)
    codeButton.enabled = false
  }
  
  private func loginEaseMob() {
    let userID = AccountManager.sharedInstance().userID
    let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
    print("Username: \(userID)")
    print("登陆前环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    EaseMob.sharedInstance().chatManager.loginWithUsername(userID, password: "123456", error: error)
    print("登陆后环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
    if error != nil {
      showHint(error.debugDescription)
    }
    EaseMob.sharedInstance().chatManager.loadDataFromDatabase()
    let options = EaseMob.sharedInstance().chatManager.pushNotificationOptions
    options.displayStyle = .ePushNotificationDisplayStyle_simpleBanner
    EaseMob.sharedInstance().chatManager.asyncUpdatePushOptions(options)
  }

  // MARK: Button Action
  
  @IBAction func tappedCodeButton(sender: UIButton) {
    guard let phone = phoneTextField.text else { return }
    
    if ZKJSTool.validateMobile(phone) {
      ZKJSTool.showMsg("验证码已发送")
      HttpService.sharedInstance.requestSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
        self.codeTextField.becomeFirstResponder()
        self.codeButton.enabled = false
        self.codeButton.alpha = 0.5
        self.count = 30
        self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
        if let json = json {
         
        }
      })//      // 发送验证码
//      ZKJSLocationHTTPSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phone, success: { (task: NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
//        print(responsObject)
//        ZKJSTool.showMsg("验证码已发送")
//        self.codeTextField.becomeFirstResponder()
//        self.codeButton.enabled = false
//        self.codeButton.alpha = 0.5
//        self.count = 30
//        self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
//        }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
//          
////      })(phone, callback: { (success: Bool, error: NSError!) -> Void in
////        if success {
////          ZKJSTool.showMsg("验证码已发送")
////          self.codeTextField.becomeFirstResponder()
////          self.codeButton.enabled = false
////          self.codeButton.alpha = 0.5
////          self.count = 30
////          self.countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
////        } else {
////          if let userInfo = error.userInfo.first {
////            self.showHint(userInfo.1 as! String)
////          }
////        }
//      })
//    } else {
//      ZKJSTool.showMsg("手机格式错误")
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
        codeButton.layer.borderColor = UIColor(hexString: "C7C7CD").CGColor
        codeButton.backgroundColor = UIColor.whiteColor()
        codeButton.setTitleColor(UIColor(hexString: "C7C7CD"), forState: .Normal)
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
        nextStep()
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

