//
//  EmailVC.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class EmailVC: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("EmailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "修改邮箱"
    emailTextField.text = AccountManager.sharedInstance().email
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  @IBAction func done(sender: AnyObject) {
    guard let email = emailTextField.text?.trim else { return }
    if ZKJSTool.validateEmail(email) == false {
      showHint("邮箱格式有误")
      return
    }

    HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: nil, image: nil, email: email,silentmode: nil) {[unowned self] (json, error) -> () in
      if let _ = error {
        self.showHint("修改邮箱失败")
      } else {
      AccountManager.sharedInstance().saveEmail(email)
      self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
  
}

extension EmailVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
