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
  
  let dataArray = NSMutableArray()
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
    headerView.textField.placeholder = "入住人"
//    tableView.tableHeaderView = headerView
    
    // Footer View
    footerView = NSBundle.mainBundle().loadNibNamed(NewItemFooterView.nibName(), owner:self, options:nil).first as! NewItemFooterView
    footerView.doneButton.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
//    tableView.tableFooterView = footerView
    
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
  
  // MARK: - Public
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getGuestListSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? NSArray {
        self.dataArray.addObjectsFromArray(arr as [AnyObject])
        self.tableView.reloadData()
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      ZKJSTool.showMsg("加载失败")
    })
  }
  func done() {
    if headerView.textField.text.isEmpty {
      ZKJSTool.showMsg("请填写内容")
      return
    }
    
    selection(headerView.textField.text)
    navigationController?.popViewControllerAnimated(true)
    
    for dic in self.dataArray {
      if let d = dic as? [String: String] {
        if d["realname"] == headerView.textField.text {
          return
        }
      }
    }
    
    let param = ["realname" : headerView.textField.text]
    ZKJSHTTPSessionManager.sharedInstance().addGuestWithParam(param as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
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
    return 8.0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NewItemCell.reuseIdentifier()) as! NewItemCell
    if let dic = dataArray[indexPath.row] as? NSDictionary {
      cell.receiptNO.text = "入住人 \(indexPath.row + 1)"
      cell.title.text = dic["realname"] as? String
    }
//    cell.receiptNO.text = ""
//    cell.title.text = "入住人姓名一"
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewItemCell
    headerView.textField.text = cell.title.text
  }

}
