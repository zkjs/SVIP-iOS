//
//  BookingOrderTVC.swift
//  SVIP
//
//  Created by Hanton on 8/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class BookingOrderTVC: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "确定订单"
  }
  
  // MARK: - Table view data source
  
//  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    return 3
//  }
  
//  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    var rows = 0
//    switch section {
//    case 0:
//      rows = 2
//    case 1:
//      rows = 2
//    case 2:
//      rows = 2
//    default:
//      break
//    }
//    return rows
//  }
  
//  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    return UITableViewCell()
//  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
  }
  
}
