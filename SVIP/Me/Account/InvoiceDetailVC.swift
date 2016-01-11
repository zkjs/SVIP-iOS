//
//  InvoiceDetailVC.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

enum InvoiceDetailType: Int {
  case Add = 0
  case Update = 1
}

class InvoiceDetailVC: UIViewController {
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var isDefaultButton: UIButton!
  
  var type = InvoiceDetailType.Add
  var invoice = InvoiceModel()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InvoiceDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleTextField.text = invoice.title
    isDefaultButton.selected = invoice.isDefault
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    view.endEditing(true)
  }
  
  @IBAction func tappedIsDefaultButton(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction func tappedDoneButton(sender: UIButton) {
    switch type {
    case .Add:
      addInvoice()
    case .Update:
      updateInvoice()
    }
    
  }
  
  func addInvoice() {
    guard let title = titleTextField.text else { return }
    if titleTextField.text == "" {
      showHint("请填写发票信息")
      return
    }
    ZKJSHTTPSessionManager.sharedInstance().addInvoiceWithTitle(title, isDefault: isDefaultButton.selected, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue {
            self.showHint("新增成功")
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
  func updateInvoice() {
    guard let title = titleTextField.text else { return }
    ZKJSHTTPSessionManager.sharedInstance().modifyInvoiceWithInvoiceid(invoice.id, title: title, isDefault: isDefaultButton.selected, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue {
            self.showHint("保存成功")
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
}

extension InvoiceDetailVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
