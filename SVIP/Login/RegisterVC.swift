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
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  
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
    
    guard let code = codeTextField.text else {return}
    
    ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(code, mobilePhoneNumber: phone) { (success: Bool, error: NSError!) -> Void in
      if success {
        self.loginWithPhone(phone)
      } else {
        self.hideHUD()
        self.showHint("验证码不正确")
      }
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
  
  private func loginWithPhone(phone: String) {
    ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID(phone, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            // 已注册
            // 缓存userid和token
            AccountManager.sharedInstance().saveAccountInfo(data)
            // 获取用户信息
//            self.getUserInfo() {
//              self.hideHUD()
//              self.dismissSelf()
//              let userid = AccountManager.sharedInstance().userID
//              MobClick.profileSignInWithPUID(userid)
//              
//            }
          } else {
          }
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.hideHUD()
        self.showHint("服务器返回数据异常")
    })
  }
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    view.endEditing(true)
  }

  
  func backToLoginVC(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
    
  @IBAction func register(sender: AnyObject) {
    guard let phone = phoneTextField.text,let code = codeTextField.text else {return}
    HttpService.sharedInstance.registerWithPhoneNumber(phone, code: code) { (json, error) -> () in
      let vc = InfoEditVC()
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

}

extension RegisterVC:UITextFieldDelegate {
  func textFieldDidEndEditing(textField: UITextField) {
    textField.resignFirstResponder()
  }
}

