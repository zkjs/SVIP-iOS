//
//  NameTVC.swift
//  SVIP
//
//  Created by Hanton on 9/8/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

typealias NameSelectionBlock = (String) -> ()

class NameTVC: UITableViewController, UITextFieldDelegate {

  var headerView: NewItemHeaderView!
  var footerView: NewItemFooterView!
  var selection: NameSelectionBlock!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor(hexString: "EFEFF4")
    tableView.separatorStyle = .None
    
    // Cell
    let cellNib = UINib(nibName: NewItemCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: NewItemCell.reuseIdentifier())
    
    // Header View
    headerView = NSBundle.mainBundle().loadNibNamed(NewItemHeaderView.nibName(), owner:self, options:nil).first as! NewItemHeaderView
    headerView.textField.delegate = self
    //    tableView.tableHeaderView = headerView
    
    // Footer View
    footerView = NSBundle.mainBundle().loadNibNamed(NewItemFooterView.nibName(), owner:self, options:nil).first as! NewItemFooterView
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
    return NewItemCell.height()
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 8.0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NewItemCell.reuseIdentifier()) as! NewItemCell
    cell.receiptNO.text = ""
    cell.title.text = "入住人姓名一"
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewItemCell
    headerView.textField.text = cell.title.text
  }

}
