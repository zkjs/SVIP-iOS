//
//  OrderListTVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class OrderListTVC: UITableViewController {

  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "足迹"
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    let cellNib = UINib(nibName: OrderCell.nibName(), bundle: nil)
    self.tableView.registerNib(cellNib, forCellReuseIdentifier: OrderCell.reuseIdentifier())
    self.tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    self.tableView.separatorStyle = .None
    self.tableView.contentInset = UIEdgeInsets(top: -OrderListHeaderView.height(), left: 0.0, bottom: 0.0, right: 0.0)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return OrderCell.height()
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return OrderListHeaderView.height()
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return OrderListHeaderView.header()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: OrderCell = tableView.dequeueReusableCellWithIdentifier(OrderCell.reuseIdentifier()) as! OrderCell
    
    // Configure the cell...
    
    return cell
  }

  // MARK: - Private Method
  
  func loadMoreData() -> Void {
    self.tableView.reloadData()
    self.tableView.footer.noticeNoMoreData()
//    self.tableView.footer.endRefreshing()
  }
  
  func dismissSelf() -> Void {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

}
