//
//  OrderListTVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import Foundation

extension NSDate {
  class func daysFromDate(fromDate: NSDate, toDate: NSDate) -> Int {
    var startingDate: NSDate? = nil
    var resultDate: NSDate? = nil
    let calendar = NSCalendar.currentCalendar()
    calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &startingDate, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &resultDate, interval: nil, forDate: toDate)
    let dateComponets = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions.allZeros)
    return dateComponets.day
  }
}

class OrderListTVC: UITableViewController, BookingOrderDetailVCDelegate {
  
  var orders: NSMutableArray = []
  var orderPage = 1

  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "足迹"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    let cellNib = UINib(nibName: OrderCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: OrderCell.reuseIdentifier())
    tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    tableView.footer.hidden = true
    tableView.separatorStyle = .None
    tableView.contentInset = UIEdgeInsets(top: -OrderListHeaderView.height(), left: 0.0, bottom: 0.0, right: 0.0)
    
    loadMoreData()
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
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
    if orders.count == 0 {
      return UITableViewCell()
    }
    
    let cell: OrderCell = tableView.dequeueReusableCellWithIdentifier(OrderCell.reuseIdentifier()) as! OrderCell
    let order = orders[indexPath.row] as! NSDictionary
    cell.logoImageView.image = UIImage(named: "img_hotel_anli01")
    let startDateString = order["arrival_date"] as! String
    let endDateString = order["departure_date"] as! String
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(startDateString)
    let endDate = dateFormatter.dateFromString(endDateString)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    let status = order["status"] as! String
    let room_rate_string = order["room_rate"] as! NSString
    let room_rate = Int(room_rate_string.doubleValue)
    let rooms = order["rooms"] as! String
    
    if status.toInt() == 0 {
      cell.bookingImageView.hidden = false
      cell.amountLabel.hidden = true
    } else {
      cell.bookingImageView.hidden = true
      cell.amountLabel.hidden = false
      cell.amountLabel.text = "¥\(room_rate * rooms.toInt()! * days)"
    }
    dateFormatter.dateFormat = "yyyy/MM/dd"
    cell.dateLabel.text = dateFormatter.stringFromDate(startDate!)
    cell.nameLabel.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    cell.countLabel.text = "\(days)晚"
    
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let order = orders[indexPath.row] as! NSDictionary
    let status = order["status"] as! String
    
    if status.toInt() == 0 {
      let bookingOrderDetailVC = BookingOrderDetailVC(order: order)
      bookingOrderDetailVC.delegate = self
      navigationController?.pushViewController(bookingOrderDetailVC, animated: true)
    } else {
      navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
    }
  }
  
  // MARK: - BookingOrderDetailVCDelegate
  func didCancelOrder(order: NSDictionary) {
    orders.removeObject(order)
    tableView.reloadData()
  }

  // MARK: - Private Method
  func loadMoreData() -> Void {
    let userID = "557cff54a9a97"
    let token = "wzWqj5elcC50gosP"
    let page = String(orderPage)
    ZKJSHTTPSessionManager.sharedInstance().getOrderListWithUserID(userID, token: token, page: page, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.tableView.footer.hidden = false
      let orderArray = responseObject as! NSArray
      if orderArray.count != 0 {
        self.orders.addObjectsFromArray(orderArray as [AnyObject])
        self.tableView.reloadData()
        self.tableView.footer.endRefreshing()
        self.orderPage++
      } else {
        self.tableView.footer.noticeNoMoreData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
  
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
