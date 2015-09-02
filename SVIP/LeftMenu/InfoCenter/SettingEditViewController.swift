//
//  SettingEditViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/14.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
enum VCType {
  case realname
  case username
  case company
  case email
}
class SettingEditViewController: UIViewController {
  let type: VCType
  let editDic: NSDictionary
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var promptLabel: UILabel!
  required init(type: VCType) {
    self.type = type
    let path = NSBundle.mainBundle().pathForResource("SettingEdit", ofType: "plist")
    editDic = NSDictionary(contentsOfFile:path!)!
    super.init(nibName: "SettingEditViewController", bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
  }
  
  func setUI() {
    let baseInfo = JSHStorage.baseInfo()
    switch type {
    case VCType.realname:
      textField.text = baseInfo.real_name;
      if let dic = editDic["realname"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    case VCType.username:
      textField.text = baseInfo.username
      if let dic = editDic["username"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
      
    case VCType.company:
      textField.text = baseInfo.company
      if let dic = editDic["company"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    
    case VCType.email:
      textField.text = baseInfo.email
      if let dic = editDic["email"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    default: break
    }
  }
  
  @IBAction func save(sender: UIButton) {
    var username:String?
    var realname:String?
    var company:String?
    var email:String?
    if textField.text.isEmpty {
      ZKJSTool.showMsg("请填写信息")
      return
    }
    switch type {
    case VCType.realname:
      realname = textField.text
    case VCType.username:
      username = textField.text
    case VCType.company:
      company = textField.text
    case VCType.email:
      if ZKJSTool.validateEmail(textField.text) {
        email = textField.text
      }else {
        ZKJSTool.showMsg("邮箱格式不正确")
        return
      }
    default: break
    }
    
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: username, realname:realname, imageData: nil, imageName: nil, sex: nil, company: company, occupation: nil, email:email, tagopen:nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        let set = dic["set"]!.boolValue!
        if set {
          let baseInfo = JSHStorage.baseInfo()
          switch self.type {
          case VCType.realname:
            baseInfo.real_name = realname
          case VCType.username:
            baseInfo.username = username
          case VCType.company:
            baseInfo.company = company
          case VCType.email:
            baseInfo.email = email
          default: break
          }
          JSHStorage.saveBaseInfo(baseInfo)
        }
      }
      self.navigationController?.popViewControllerAnimated(true)
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
}
