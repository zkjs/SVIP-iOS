//
//  LoginFirstVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/29.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class LoginFirstVC: UIViewController {

  @IBOutlet weak var phonetextFiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.navigationBarHidden = true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
    
  @IBAction func register(sender: AnyObject) {
    let vc = LoginVC()
    guard let  str = self.phonetextFiled.text where str != "请输入您的手机号" else {
      self.showHint("请输入手机号")
      return
    }
    if !str.isMobile {
      self.showHint("请输入正确的手机号")
      return
    }
    vc.phone = str
    vc.type = CodeType.Register
    let nv = BaseNC(rootViewController:vc)
    self.navigationController?.presentViewController(nv, animated: true, completion: nil)
    
  }


  @IBAction func start(sender: AnyObject) {
    let vc = LoginVC()
    guard let  str = self.phonetextFiled.text where str != "请输入您的手机号" else {
      self.showHint("请输入手机号")
      return
    }
    if !str.isMobile {
      self.showHint("请输入正确的手机号")
      return
    }
    vc.phone = str
    vc.type = CodeType.Login
    self.navigationController?.presentViewController(vc, animated: true, completion: { () -> Void in
    
    })
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginFirstVC:UITextFieldDelegate {
  
 
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField.text == "请输入您的手机号" {
      textField.text = ""
    }
    textField.layer.masksToBounds = true
    textField.layer.cornerRadius = 3.0
    textField.layer.borderWidth = 1.0
    textField.layer.borderColor = UIColor.ZKJS_mainColor().CGColor
    self.view.frame.origin = CGPoint(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y-50)
    return true
  }
  func textFieldDidEndEditing(textField: UITextField) {
    if textField.text == "" {
      textField.text = "请输入您的手机号"
    }
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    textField.layer.borderWidth = 0
    self.view.frame.origin = CGPoint(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y)
    return true
  }
  
  

  
}
