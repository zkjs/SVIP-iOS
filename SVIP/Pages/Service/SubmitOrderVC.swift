//
//  SubmitServiceVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

protocol SubmitOrderDelegate {
  func SubmitSuccess()
  func submitFail()
}

class SubmitOrderVC: UIViewController {
  var srvid:String!
  var locid:String!
  var delegate:SubmitOrderDelegate?
  
  @IBOutlet weak var remarkTextField: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  @IBAction func submitAction(sender: AnyObject) {
    remarkTextField.resignFirstResponder()
    showHudInView(view, hint: "")
    HttpService.sharedInstance.createOrder(srvid, locid: locid, remark: getRemark()) { (json, error) in
      self.hideHUD()
      if let error = error {
        self.showErrorHint(error)
      } else {
        self.showHint("服务呼叫成功")
        self.navigationController?.popViewControllerAnimated(false)
        self.delegate?.SubmitSuccess()
      }
    }
  }
  
  func getRemark() -> String {
    let text = remarkTextField.text.trim
    return text == "备注" ? "" : text
  }
  
}

extension SubmitOrderVC:UITextViewDelegate {
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    if textView.text.trim == "备注" {
      textView.text = ""
    }
    return true
  }
  
}
