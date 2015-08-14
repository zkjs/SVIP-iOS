//
//  SettingEditViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/14.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
enum VCType {
  case name
  case nickname
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
    case VCType.name:
      if let dic = editDic["name"] as? NSDictionary {
        if let placeholder = dic["placeholder"] as? String {
          textField.placeholder = placeholder
        }
        if let prompt = dic["prompt"] as? String {
          promptLabel.text = prompt
        }
      }
    case VCType.nickname:
      if let dic = editDic["nickname"] as? NSDictionary {
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
    
  }
}
