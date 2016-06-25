//
//  MyOrdersTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import MJRefresh

class MyOrdersTVC: UITableViewController {
  
  var orders = [MyOrder]()
  var page = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "呼叫列表"
    
    tableView.tableFooterView = UIView()
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    loadData()
  }
  
  func loadData() {
    page = 0
    getOrders(page)
  }
  
  func loadMore() {
    page += 1
    getOrders(page)
  }
  
  func getOrders(page:Int) {
    showHudInView(view, hint: "")
    HttpService.sharedInstance.getMyOrders(page) { (orders, error) in
      self.hideHUD()
      self.tableView.mj_header.endRefreshing()
      self.tableView.mj_footer.endRefreshing()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if orders.count < HttpService.DefaultPageSize {
          self.tableView.mj_footer.hidden = true
        } else {
          self.tableView.mj_footer.hidden = false
        }
        if orders.count == 0 {
          if page == 0 {
            self.showHint("没有呼叫服务")
          }
        } else {
          if page > 0 {
            self.orders += orders
          } else {
            self.orders = orders
          }
          self.tableView.reloadData()
        }
      }
    }
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MyOrderCell", forIndexPath: indexPath) as! MyOrderCell
    cell.order = orders[indexPath.row]
    return cell
  }

}
