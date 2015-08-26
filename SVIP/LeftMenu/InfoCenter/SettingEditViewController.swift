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
    switch type {
    case VCType.realname:
      if let dic = editDic["realname"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    case VCType.username:
      if let dic = editDic["username"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
      
    case VCType.company:
      if let dic = editDic["company"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    
    case VCType.email:
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
    switch type {
    case VCType.realname:
      if !textField.text.isEmpty {
        realname = textField.text
      }
    case VCType.username:
      if !textField.text.isEmpty {
        username = textField.text
      }
      
    case VCType.company:
      if !textField.text.isEmpty {
        company = textField.text
      }
    case VCType.email:
      if !textField.text.isEmpty {
        email = textField.text
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
