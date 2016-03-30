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
  
  @IBOutlet weak var nameTextFiled: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()

  let image = UIImage(named: "ic_fanhui_orange")
  let item = UIBarButtonItem(image: image, style:.Done, target: self, action: "backToLoginVC:")
  self.navigationController?.navigationItem.leftBarButtonItem = item
  

}
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("RegisterVC", owner:self, options:nil)
  }
  
  @IBAction func nextStep(sender: AnyObject) {
    let vc = InfoEditVC()
    guard let str = nameTextFiled.text where !str.isEmpty else {
      self.showHint("请填写姓名")
      return
    }
    vc.username = str
    self.navigationController?.presentViewController(vc, animated: true, completion: nil)
     
    
  }
  
}
   
