//
//  MessageCenterTVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class MessageCenterTVC: UITableViewController {
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "消息中心"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    let cellNib = UINib(nibName: HotelMessageCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: HotelMessageCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 82
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell: HotelMessageCell = tableView.dequeueReusableCellWithIdentifier(HotelMessageCell.reuseIdentifier()) as! HotelMessageCell
  
    cell.name.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    
    if let chatMessage = StorageManager.sharedInstance().lastChatMessage("120") {
      cell.tips.text = chatMessage["message"]
      cell.date.text = chatMessage["date"]
    }
    
    if let order = StorageManager.sharedInstance().lastOrder() {
      if let status = order.status {
        switch status {
          case "0":
          cell.status.text = "可取消"
          case "1":
          cell.status.text = "已取消"
          case "2":
          cell.status.text = "已确定"
          case "3":
          cell.status.text = "已完成"
          case "5":
          cell.status.text = "已删除"
        default:
          break
        }
      }
    }
    
    if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
      cell.logo.badgeString = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let chatVC = JSHChatVC(chatType: ChatType.OldSession)
    chatVC.shopID = "120"
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Private Method
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }

}
