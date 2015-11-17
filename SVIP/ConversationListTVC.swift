//
//  ConversationListTVC.swift
//  SVIP
//
//  Created by Hanton on 11/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class ConversationListTVC: UITableViewController, IChatManagerDelegate {
  
  var dataArray = [AnyObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "服务中心"
    
    let leftBarButton = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismiss")
    navigationItem.leftBarButtonItem = leftBarButton
    
    EaseMob.sharedInstance().chatManager.removeDelegate(self)
    EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
    
    let cellNib = UINib(nibName: ConversationCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: ConversationCell.reuseIdentifier())
    
    tableView.tableFooterView = UIView()
    
    reloadDataSource()
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("ConversationListTVC", owner:self, options:nil)
  }
  
  deinit {
    EaseMob.sharedInstance().chatManager.removeDelegate(self)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Public
  
  func dismiss() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Data
  
  func reloadDataSource() {
    dataArray.removeAll()
    
    EaseMob.sharedInstance().chatManager.asyncFetchMyGroupsListWithCompletion({ (groups: [AnyObject]!, error: EMError!) -> Void in
      self.dataArray.appendContentsOf(groups)
      print(self.dataArray.count)
      self.tableView.reloadData()
      }, onQueue: nil)
  }
  
  // MARK: - IChatManagerDelegate
  
  func groupDidUpdateInfo(group: EMGroup!, error: EMError!) {
    if error == nil {
      reloadDataSource()
    }
  }
  
  func didUpdateGroupList(groupList: [AnyObject]!, error: EMError!) {
    reloadDataSource()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ConversationCell.height()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ConversationCell.reuseIdentifier()) as! ConversationCell
    
    let group = dataArray[indexPath.row] as! EMGroup
    cell.setData(group)
    
    return cell
  }
  
  // MARK: - Tabel view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
}
