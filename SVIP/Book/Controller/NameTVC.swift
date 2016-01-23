//
//  NameTVC.swift
//  SVIP
//
//  Created by Hanton on 9/8/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

typealias NameSelectionBlock = (String, Int) -> ()

class NameTVC: UITableViewController, UITextFieldDelegate {

  var headerView: NewItemHeaderView!
  var footerView: NewItemFooterView!
  var selection: NameSelectionBlock!
  var selectedRow: Int! = 0
  
  let dataArray = NSMutableArray()
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = UIColor(hexString: "#EFEFF4")
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
    navigationController?.hidesBarsOnSwipe = true
    tableView.tableHeaderView = headerView
    tableView.tableFooterView = footerView
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.hidesBarsOnSwipe = false
  }
  
  // MARK: - Public
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getGuestListWithSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? NSArray {
        self.dataArray.addObjectsFromArray(arr as [AnyObject])
        self.tableView.reloadData()
      }
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.showHint("加载失败")
    })
  }
  func done() {
    if headerView.textField.text!.isEmpty {
      self.showHint("请填写内容")
      return
    }
    selection(headerView.textField.text!,selectedRow)
    navigationController?.popViewControllerAnimated(true)
     for dic in self.dataArray {
      if let d = dic as? NSDictionary {
        if let realname = d["realname"] as? String {
          if realname == headerView.textField.text {
            return
          }
        }
      }
    }
    let param = ["realname" :headerView.textField.text!]
    let paramDic = NSDictionary(dictionary: param)
    ZKJSHTTPSessionManager.sharedInstance().addGuestWithParam(paramDic as [NSObject : AnyObject], success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
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
    headerView.textField.placeholder = "入住人"
    return headerView
  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    footerView = NSBundle.mainBundle().loadNibNamed(NewItemFooterView.nibName(), owner:self, options:nil).first as! NewItemFooterView
    footerView.doneButton.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
    return footerView
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NewItemCell.reuseIdentifier()) as! NewItemCell
    if let dic = dataArray[indexPath.row] as? NSDictionary {
      cell.receiptNO.text = "入住人 \(indexPath.row + 1)"
      cell.title.text = dic["realname"] as? String
    }
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewItemCell
    headerView.textField.text = cell.title.text
    selectedRow = self.dataArray[indexPath.row]["id"]!!.integerValue
  }

}
