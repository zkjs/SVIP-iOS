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
  var titleLabel = UILabel()
  var find = UIButton()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MailListTVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nibName = UINib(nibName: MailListCell.nibName(), bundle: nil)
    tableView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
    tableView.registerNib(nibName, forCellReuseIdentifier: MailListCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
    layoutHind()
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "loadFriendListData")  // 下拉刷新
  }
  
  func layoutHind() {
    if contactArray.count == 0 {
      let screenSize = UIScreen.mainScreen().bounds
      emptyLabel.frame = CGRectMake(0.0, 30, 300.0, 50.0)
      emptyLabel.textAlignment = .Center
      emptyLabel.font = UIFont.systemFontOfSize(14)
      emptyLabel.text = "暂无联系人"
      emptyLabel.textColor = UIColor.ZKJS_promptColor()
      emptyLabel.center = CGPointMake(screenSize.midX, 17)
      emptyLabel.hidden = false
      view.addSubview(emptyLabel)
      
      titleLabel = UILabel(frame: CGRectMake(0.0, 30, 300.0, 45.0))
      titleLabel.textAlignment = .Center
      titleLabel.font = UIFont.systemFontOfSize(16)
      titleLabel.text = "在这里，您可以与专属客服进行沟通"
      titleLabel.textColor = UIColor.ZKJS_promptColor()
      titleLabel.center = CGPointMake(screenSize.midX, 220)
      titleLabel.hidden = false
      view.addSubview(titleLabel)
      
      find = UIButton(frame: CGRectMake(0.0, 30, 160, 40.0))
      find.setTitle("发现服务", forState: .Normal)
      find.titleLabel?.textAlignment = .Center
      find.titleLabel!.font = UIFont.systemFontOfSize(14)
      find.backgroundColor = UIColor.ZKJS_mainColor()
      find.center = CGPointMake(screenSize.midX, 278)
      find.hidden = false
      find.addTarget(self, action: "gotoShopList", forControlEvents: .TouchUpInside)
      view.addSubview(find)
    }

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadFriendListData()
  }
  
  func gotoShopList() {
    tabBarController?.selectedIndex = 1
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
          self.titleLabel.hidden = true
          self.find.hidden = true
        } else {
          self.emptyLabel.hidden = false
          self.titleLabel.hidden = false
          self.find.hidden = false
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
    cell.contactImageView.tag = indexPath.row
    let tap = UITapGestureRecognizer(target: self, action: Selector("tappedContactImage:"))
    tap.delegate = self
    cell.contactImageView.addGestureRecognizer(tap)
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let contact = contactArray[indexPath.row]
    let vc = ChatViewController(conversationChatter: contact.fuid, conversationType: .eConversationTypeChat)
    vc.hidesBottomBarWhenPushed = true
    vc.title = contact.fname
    // 扩展字段
    let userName = AccountManager.sharedInstance().userName
    let ext = ["shopId": contact.shopid ?? "",
      "shopName": contact.shop_name ?? "",
      "toName": contact.fname,
      "fromName": userName]
    vc.conversation.ext = ext
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

// MARK: - UIGestureRecognizerDelegate 

extension MailListTVC: UIGestureRecognizerDelegate {
  
  func tappedContactImage(sender: UIGestureRecognizer) {
    let contactImageView = sender.view as! UIImageView
    let contact = contactArray[contactImageView.tag]
    if contact.fuid == "app_customer_service" {
      let vc = WebViewVC()
      vc.hidesBottomBarWhenPushed = true
      vc.url = "http://www.zkjinshi.com/about_us/"
      navigationController?.pushViewController(vc, animated: true)
    } else {
      let vc = SalesDetailVC()
      vc.hidesBottomBarWhenPushed = true
      vc.salesid = contact.fuid
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

// MARK: - XLPagerTabStripChildItem

extension MailListTVC: XLPagerTabStripChildItem {
  
  func titleForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> String! {
    return "通讯录"
  }
  
  func colorForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> UIColor! {
    return UIColor.ZKJS_mainColor()
  }
  
}

