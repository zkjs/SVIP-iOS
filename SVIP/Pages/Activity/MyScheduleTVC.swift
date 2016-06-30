//
//  MyScheduleTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import MJRefresh

class MyScheduleTVC: UITableViewController {
  var data = [MySchedule]()
  var page = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "我的行程"
    
    tableView.tableFooterView = UIView()
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    loadData()
  }
  
  func loadData() {
    page = 0
    getSchedule(page)
  }
  
  func loadMore() {
    page += 1
    getSchedule(page)
  }
  
  func getSchedule(page:Int) {
    showHudInView(view, hint: "")
    HttpService.sharedInstance.getMySchedule(page) { (data, error) in
      self.hideHUD()
      self.tableView.mj_header.endRefreshing()
      self.tableView.mj_footer.endRefreshing()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if data.count < HttpService.DefaultPageSize {
          self.tableView.mj_footer.hidden = true
        } else {
          self.tableView.mj_footer.hidden = false
        }
        if data.count == 0 {
          if page == 0 {
            self.showHint("没有行程")
          }
        } else {
          if page > 0 {
            self.data += data
          } else {
            self.data = data
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
    return data.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 90
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath) as! ScheduleCell
    cell.schedule = data[indexPath.row]
    return cell
  }

}
