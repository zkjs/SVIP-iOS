//
//  RegisterVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
import Spring

class RegisterVC: UIViewController {
  
  @IBOutlet weak var bottomBorder: UILabel!
  @IBOutlet weak var nameTextFiled: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()

  //let image = UIImage(named: "ic_fanhui_orange")
  //let item = UIBarButtonItem(image: image, style:.Done, target: self, action: "backToLoginVC:")
  //self.navigationController?.navigationItem.leftBarButtonItem = item
  

}
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("RegisterVC", owner:self, options:nil)
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.navigationBarHidden = true
    
    let str = NSAttributedString(string: "仅用于支付识别与安全认证", attributes: [NSForegroundColorAttributeName:UIColor(hex: "#888888")])
    nameTextFiled.attributedPlaceholder = str
  }
  
  @IBAction func nextStep(sender: AnyObject) {
    let vc = InfoEditVC()
    guard let str = nameTextFiled.text where !str.isEmpty else {
      self.showHint("请填写姓名")
      return
    }
    if !nameTextFiled.text!.isValidName {
      showHint("填写不合符规范，请填写真实姓名")
      return
    }
    if nameTextFiled.text!.characters.count > 12 {
      showHint("姓名不超过12个中文字符")
      return
    }
    vc.username = str
    let nv = BaseNC(rootViewController:vc)
    self.navigationController?.presentViewController(nv, animated: true, completion: nil)
     
    
  }
  
  
  @IBAction func showTips(sender: UIButton) {
    let vc = TipsBubble()
    vc.anglePoint = sender.center
    vc.modalPresentationStyle = .Custom
    presentViewController(vc, animated: false, completion: nil)
  }
  
}

extension RegisterVC:UITextFieldDelegate {
  func textFieldDidBeginEditing(textField: UITextField) {
    if textField.text == "仅用于支付识别与安全认证" {
      textField.text = ""
    }
  }
}
   

