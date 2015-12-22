//
//  MailListTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MailListTVC: UITableViewController {
  
  var contactArray = [ContactModel]()
  var emptyLabel = UILabel()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MailListTVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nibName = UINib(nibName: MailListCell.nibName(), bundle: nil)
    tableView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
    tableView.registerNib(nibName, forCellReuseIdentifier: MailListCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
    
    emptyLabel.frame = CGRectMake(0.0, 0.0, 150.0, 30.0)
    let screenSize = UIScreen.mainScreen().bounds
    emptyLabel.font = UIFont.systemFontOfSize(14)
    emptyLabel.textAlignment = .Center
    emptyLabel.text = "暂无联系人"
    emptyLabel.textColor = UIColor.ZKJS_promptColor()
    emptyLabel.center = CGPointMake(screenSize.midX, screenSize.midY - 60.0)
    emptyLabel.hidden = false
    view.addSubview(emptyLabel)
    
//    loadFriendListData()
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "loadFriendListData")  // 下拉刷新
  }
  
  func loadFriendListData() {
    ZKJSHTTPSessionManager.sharedInstance().managerFreindListWithFuid("", set: "showFriend", success: { (task:NSURLSessionDataTask!, responsObjects: AnyObject!) -> Void in
//      print(responsObjects)
      if let array = responsObjects as? NSArray {
        self.contactArray.removeAll()
        for dic in array {
          let contact = ContactModel(dic: dic as! [String: AnyObject])
          self.contactArray.append(contact)
        }
        if self.contactArray.count > 0 {
          self.emptyLabel.hidden = true
        } else {
          self.emptyLabel.hidden = false
        }
        self.tableView.reloadData()
      }
      self.tableView.mj_header.endRefreshing()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.tableView.mj_header.endRefreshing()
    }
  }
  
  func dismissSelf() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contactArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return MailListCell.height()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(MailListCell.reuseIdentifier(), forIndexPath: indexPath) as! MailListCell
    let contact = contactArray[indexPath.row]
    cell.setData(contact)
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let contact = contactArray[indexPath.row]
    let vc = SalesDetailVC()
    vc.hidesBottomBarWhenPushed = true
    vc.salesid = contact.fuid
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}

extension MailListTVC: XLPagerTabStripChildItem {
  
  func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
    return "通讯录"
  }
  
  func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
    return UIColor.ZKJS_mainColor()
  }
  
}

