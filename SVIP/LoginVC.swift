//
//  LoginVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/1.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
  
  @IBOutlet weak var phoneTextField: UITextField!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LoginVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
  }
  
  func login() {
    ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID("phone", success: { (task:NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
      if let data = responsObjects {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
              
            })
          }
        }
      }
      
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  func signup() {
    guard let phone = phoneTextField.text else { return }
    ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID(phone, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            //已注册
            //save account data
            //获取用户信息
          } else {
            
          }
        }
//        if newRegister {
//          //新注册
//          ZKJSHTTPSessionManager.sharedInstance().userSignUpWithPhone(phone, openID: nil, success: { (task: NSURLSessionDataTask!, responseObject :AnyObject!) -> Void in
//            if let dic = responseObject as? [NSObject : AnyObject] {
//              let set = dic["set"]!.boolValue!
//              if set {
//                //注册成功
//                //save account data
//                //self.easeMobAutoLogin()
//                //编辑个人信息
//              }
//            }
//            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//              
//          })
//        } else {
//          
//        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    })
  }
  
  @IBAction func login(sender: AnyObject) {
    login()
  }
  
  @IBAction func dismiss(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
