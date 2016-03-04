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
      HttpService.registerSmsCodeWithPhoneNumber(phone, completionHandler: { (json, error) -> () in
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
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func backToLoginVC(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
    
  @IBAction func register(sender: AnyObject) {
    guard let phone = phoneTextField.text,let code = codeTextField.text else {return}
    HttpService.registerWithPhoneNumber(phone, code: code) { (json, error) -> () in
      let vc = InfoEditVC()
      self.navigationController?.pushViewController(vc, animated: true)
    }
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
