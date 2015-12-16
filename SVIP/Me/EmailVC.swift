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
  
  @IBAction func done(sender: AnyObject) {
    guard let email = emailTextField.text else { return }
    if ZKJSTool.validateEmail(email) == false {
      showHint("邮箱格式有误")
      return
    }
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(email, imageData: nil, sex: nil, email: nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      AccountManager.sharedInstance().saveEmail(email)
      self.navigationController?.popViewControllerAnimated(true)
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
}

extension EmailVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
