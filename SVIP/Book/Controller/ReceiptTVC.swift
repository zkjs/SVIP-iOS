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
  
  var headerView: ReceiptHeaderView!
  var footerView: ReceiptFooterView!
  var selection: ReceiptSelectionBlock!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor(hexString: "EFEFF4")
    tableView.separatorStyle = .None
    
    // Cell
    let cellNib = UINib(nibName: ReceiptCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: ReceiptCell.reuseIdentifier())
    
    // Header View
    headerView = NSBundle.mainBundle().loadNibNamed(ReceiptHeaderView.nibName(), owner:self, options:nil).first as! ReceiptHeaderView
    headerView.textField.delegate = self
//    tableView.tableHeaderView = headerView
    
    // Footer View
    footerView = NSBundle.mainBundle().loadNibNamed(ReceiptFooterView.nibName(), owner:self, options:nil).first as! ReceiptFooterView
    footerView.doneButton.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
//    tableView.tableFooterView = footerView
    
    // Tap background to dimiss keyboard
    let tap = UITapGestureRecognizer(target: self, action: "hideKeyboard")
    tap.cancelsTouchesInView = false
    tableView.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerView
  }
  
  // MARK: - Public
  
  func done() {
    selection(headerView.textField.text)
    navigationController?.popViewControllerAnimated(true)
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
    return 3
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ReceiptCell.height()
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 8.0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ReceiptCell.reuseIdentifier()) as! ReceiptCell
    cell.receiptNO.text = "发票一"
    cell.title.text = "深圳中科金石科技有限公司"
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReceiptCell
    headerView.textField.text = cell.title.text
  }
  
}
