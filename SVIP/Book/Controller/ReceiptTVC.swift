//
//  ReceiptTVC.swift
//  SVIP
//
//  Created by Hanton on 8/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

typealias ReceiptSelectionBlock = (String) -> ()

class ReceiptTVC: UITableViewController, UITextFieldDelegate {
  var dataArray: NSMutableArray!
  
  var headerView: NewItemHeaderView!
  var footerView: NewItemFooterView!
  var selection: ReceiptSelectionBlock!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor(hexString: "EFEFF4")
    tableView.separatorStyle = .None
    
    // Cell
    let cellNib = UINib(nibName: NewItemCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: NewItemCell.reuseIdentifier())
    
    // Tap background to dimiss keyboard
    let tap = UITapGestureRecognizer(target: self, action: "hideKeyboard")
    tap.cancelsTouchesInView = false
    tableView.addGestureRecognizer(tap)
    
    loadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerView
  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getInvoiceListSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? [AnyObject] {
        self.dataArray.removeAllObjects()
        for dic in arr {
          if let d = dic as? NSDictionary {
            let is_default = d["is_default"]!.boolValue!
            if is_default {//默认
              self.dataArray.insertObject(d, atIndex: 0)
            }else {//未默认
              self.dataArray.addObject(d)
            }
          }
        }
        self.tableView.reloadData()
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  // MARK: - Public
  
  func done() {
    if headerView.textField.text!.isEmpty {
      ZKJSTool.showMsg("请填写内容")
      return
    }
    
    selection(headerView.textField.text!)
    navigationController?.popViewControllerAnimated(true)
    
    for dic in self.dataArray {
      if let d = dic as? NSDictionary {
        if let invoice_title = d["invoice_title"] as? String {
          if invoice_title == headerView.textField.text {
            return
          }
        }
      }
    }
    
    ZKJSHTTPSessionManager.sharedInstance().addInvoiceWithTitle(headerView.textField.text, isDefault:false, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        let set = dic["set"]!.boolValue!
        if set {
          
        }
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
  func hideKeyboard() {
    tableView.endEditing(true)
  }
  
  // MARK: - UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return NewItemCell.height()
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return NewItemHeaderView.height()
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return NewItemFooterView.height()
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    headerView = NSBundle.mainBundle().loadNibNamed(NewItemHeaderView.nibName(), owner:self, options:nil).first as! NewItemHeaderView
    headerView.textField.delegate = self
    return headerView
  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    footerView = NSBundle.mainBundle().loadNibNamed(NewItemFooterView.nibName(), owner:self, options:nil).first as! NewItemFooterView
    footerView.doneButton.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
    return footerView
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NewItemCell.reuseIdentifier()) as! NewItemCell
    let dic = self.dataArray[indexPath.row] as! [String: String]
    cell.receiptNO.text = "发票\(indexPath.row)"
    cell.title.text = dic["invoice_title"]
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewItemCell
    headerView.textField.text = cell.title.text
  }
  
}
