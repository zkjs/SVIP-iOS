//
//  NameVC.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class NameVC: UIViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("NameVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "修改姓名"
    nameTextField.text = AccountManager.sharedInstance().userName
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  @IBAction func done(sender: AnyObject) {
    guard let userName = nameTextField.text?.trim else { return }
    if userName.isEmpty == true {
      showHint("姓名不能为空")
      return
    }
    if !userName.isValidName {
      showHint("填写不合符规范，请填写真实姓名")
      return
    }
    if userName.characters.count > 20 {
      showHint("填写的姓名超过限制长度")
      return
    }
    
    HttpService.sharedInstance.updateUserInfo(false, realname: userName, sex: nil, image: nil, email: nil,silentmode: nil) { [unowned self](json, error) -> () in
      if let error = error {
        self.showErrorHint(error)
      } else {
        AccountManager.sharedInstance().saveUserName(userName)
        self.navigationController?.popViewControllerAnimated(true)
      }
    }

    }
}

extension NameVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    view.endEditing(true)
    return true
  }
  
}
