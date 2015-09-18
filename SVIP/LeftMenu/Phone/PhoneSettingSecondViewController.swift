//
//  PhoneSettingSecondViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/26.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PhoneSettingSecondViewController: UIViewController {
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var okButton: UIButton!
  
  var countTimer: NSTimer?
  let kCountTime = 30
  var count: Int = 30
  
  convenience init() {
    self.init(nibName:"PhoneSettingSecondViewController", bundle: nil)
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
  }
  
  func refreshCount() {
    if --count == 0 {
      countTimer?.invalidate()
      okButton.enabled = true
      okButton.setTitle("发送验证码", forState: UIControlState.Disabled)
    }else {
      okButton.setTitle("\(count)S", forState: UIControlState.Disabled)
    }
  }
  @IBAction func buttonClick(sender: UIButton) {
    ZKJSHTTPSMSSessionManager.sharedInstance().requestSmsCodeWithPhoneNumber(phoneTextField.text, callback: { (successed: Bool, error: NSError!) -> Void in
      if successed {
        ZKJSTool.showMsg("验证码已发送")
      }
    })
    okButton.enabled = false
    count = kCountTime
    countTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshCount", userInfo: nil, repeats: true)
  }
  
  //MARK:- UITextField Delegate
  func textFieldDidChanged(aNotification: NSNotification) {
    let phoneText = phoneTextField.text
    let codeText = codeTextField.text
    let textfield = aNotification.object as! UITextField
    
    if phoneText?.characters.count == 11 && textfield == phoneTextField { //phoneTextField输入11位
      if ZKJSTool.validateMobile(phoneText) {
        okButton.enabled = true
      }else {
        ZKJSTool.showMsg("手机号错误")
      }
    }
    if phoneText?.characters.count < 11 && okButton.titleLabel?.text == "发送验证码" {
      okButton.enabled = false
      return
    }
    
    if phoneText?.characters.count == 11 && codeText?.characters.count == 6 {
      ZKJSHTTPSMSSessionManager.sharedInstance().verifySmsCode(codeText, mobilePhoneNumber: phoneText, callback: { (successed: Bool, error: NSError!) -> Void in
        if successed {
          let dictionary = ["phone" : phoneText!]
          ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithParaDic(dictionary, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
            let dic = responseObject as! NSDictionary
            if dic["set"]!.boolValue! {
              ZKJSTool.showMsg("电话修改成功")
              let controllers = self.navigationController!.viewControllers
              let count = controllers.count
              let vc = controllers[count - 3]
              self.navigationController?.popToViewController(vc, animated: true)
            }
            }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
              
          }

          
        }else {
          ZKJSTool.showMsg("验证码错误")
        }
      })
    }
  }
}
