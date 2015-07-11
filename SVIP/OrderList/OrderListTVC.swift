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

class OrderListTVC: UITableViewController, SWTableViewCellDelegate, BookingOrderDetailVCDelegate {
  
  var orders: NSMutableArray = []
  var orderPage = 1

  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadMoreData()
    
    title = "足迹"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    let cellNib = UINib(nibName: OrderCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: OrderCell.reuseIdentifier())
    tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    tableView.footer.hidden = true
    tableView.separatorStyle = .None
    tableView.contentInset = UIEdgeInsets(top: -OrderListHeaderView.height(), left: 0.0, bottom: 0.0, right: 0.0)
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
    
    // status=订单状态 默认0 未确认可取消订单 1取消订单 2已确认订单 3已经完成的订单 5删除订单
    if status.toInt() == 0 {
      cell.rightUtilityButtons = nil
      cell.statusLabel.text = "未确定"
    } else if status.toInt() == 1 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已取消"
    } else if status.toInt() == 2 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已确定"
    } else if status.toInt() == 3 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已完成"
    } else if status.toInt() == 4 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已入住"
    }
    
    cell.amountLabel.hidden = false
    cell.amountLabel.text = "¥\(room_rate * rooms.toInt()! * days)"
    
    dateFormatter.dateFormat = "yyyy/MM/dd"
    cell.dateLabel.text = dateFormatter.stringFromDate(startDate!)
    cell.nameLabel.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    cell.countLabel.text = "\(days)晚"
    cell.delegate = self
    
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let order = orders[indexPath.row] as! NSDictionary
    let status = order["status"] as! String
    
    if status.toInt() == 0 {  // 0 未确认可取消订单
      let bookingOrderDetailVC = BookingOrderDetailVC(order: order)
      bookingOrderDetailVC.delegate = self
      navigationController?.pushViewController(bookingOrderDetailVC, animated: true)
    } else {
      navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
    }
  }
  
  // MARK: - BookingOrderDetailVCDelegate
  func didCancelOrder(order: NSDictionary) {
    let replacedOrder = NSMutableDictionary(dictionary: order)
    replacedOrder["status"] = "1"  // 1 取消订单
    let index = orders.indexOfObject(order)
    orders.replaceObjectAtIndex(index, withObject: replacedOrder)
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  // MARK: - SWTableViewDelegate
  func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
    switch index {
    case 0:
      let indexPath = tableView.indexPathForCell(cell)!
      let order = orders[indexPath.row] as! NSDictionary
      orders.removeObjectAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
      let userID = JSHAccountManager.sharedJSHAccountManager().userid
      let token = JSHAccountManager.sharedJSHAccountManager().token
      let orderID = order["id"] as! String
      ZKJSHTTPSessionManager.sharedInstance().deleteOrderWithUserID(userID, token: token, orderID: orderID, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg("删除失败")
      })
    default:
      break
    }
  }

  // MARK: - Private Method
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func loadMoreData() -> Void {
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
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
  
  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }
  
}
