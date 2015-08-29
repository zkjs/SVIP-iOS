//
//  InvoiceEditViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/27.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class InvoiceEditViewController: UIViewController {
  let dic: NSMutableDictionary
  @IBOutlet weak var invoice: UITextField!
  @IBOutlet weak var isDefaultButton: UIButton!
  required init(dic: NSDictionary?) {
    if dic == nil {//创建新dic
      self.dic = NSMutableDictionary()
    }else {//接受传参
      self.dic = NSMutableDictionary(dictionary: dic!)
    }
    super.init(nibName: "InvoiceEditViewController", bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  convenience init() {
    self.init(dic: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    invoice.text = dic["invoice_title"] as? String
    if let is_default = dic["is_default"] as? NSNumber {
      isDefaultButton.selected = is_default.boolValue
    }
  }
  
  @IBAction func isDefaultButtonClicked(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction func save(sender: UIButton) {
    if invoice.text.isEmpty {
      ZKJSTool.showMsg("请填写内容")
      return
    }
    let is_default = isDefaultButton.selected
    let invoice_title = invoice.text
    if let invoiceid = dic["id"] as? String {//有id，即表示为修改
      ZKJSHTTPSessionManager.sharedInstance().modifyInvoiceWithInvoiceid(invoiceid, title: invoice_title, isDefault: is_default, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let dic = responseObject as? NSDictionary {
          let set = dic["set"]!.boolValue!
          if set {
            ZKJSTool.showMsg("保存成功")
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
    }else {
      ZKJSHTTPSessionManager.sharedInstance().addInvoiceWithTitle(invoice_title, isDefault: is_default, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let dic = responseObject as? NSDictionary {
          let set = dic["set"]!.boolValue!
          if set {
            ZKJSTool.showMsg("保存成功")
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      })
    }
  }
}