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
    
//    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: NSSelectorFromString("dismissSelf"))
    
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
    let order = orders[indexPath.row] as! BookOrder
    let urlString = "\(kBaseURL)uploads/shops/\(order.shopid).png"
    let logoURL = NSURL(string: urlString)
    let placeholderImage = UIImage(named: "img_hotel_zhanwei")
    cell.logoImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage, options: SDWebImageOptions.ProgressiveDownload | SDWebImageOptions.RetryFailed, completed: nil)
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(order.arrival_date)
    let endDate = dateFormatter.dateFromString(order.departure_date)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    let status = order.status
    var room_rate = 0
    if let roomRate = order.room_rate.toInt() {
      room_rate = roomRate
    }
    let rooms = order.rooms
    
    // status=订单状态 默认0 未确认可取消订单 1取消订单 2已确认订单 3已经完成的订单 4已经入住的订单 5删除订单
    if status.toInt() == 0 {
      cell.rightUtilityButtons = nil
      cell.bookingImageView.hidden = false
      cell.statusLabel.text = "未确定"
    } else if status.toInt() == 1 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已取消"
    } else if status.toInt() == 2 {
      cell.rightUtilityButtons = nil
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已确定"
    } else if status.toInt() == 3 {
      cell.rightUtilityButtons = rightButtons() as [AnyObject]
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已完成"
    } else if status.toInt() == 4 {
      cell.rightUtilityButtons = nil
      cell.bookingImageView.hidden = true
      cell.statusLabel.text = "已入住"
    }
    
    cell.amountLabel.hidden = false
    cell.amountLabel.text = "¥\(room_rate * rooms.toInt()! * days)"
    
    dateFormatter.dateFormat = "yyyy/MM/dd"
    cell.dateLabel.text = dateFormatter.stringFromDate(startDate!)
    cell.nameLabel.text = order.fullname
    cell.countLabel.text = "\(days)晚"
    cell.delegate = self
    
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let order = orders[indexPath.row] as! BookOrder
    
    if order.status.toInt() == 0 {  // 0 未确认可取消订单
      let bookingOrderDetailVC = BookingOrderDetailVC(order: order)
      bookingOrderDetailVC.delegate = self
      navigationController?.pushViewController(bookingOrderDetailVC, animated: true)
    } else {
      navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
    }
  }
  
  // MARK: - BookingOrderDetailVCDelegate
  func didCancelOrder(order: BookOrder) {
    order.status = "1"  // 1 取消订单
    let index = orders.indexOfObject(order)
    orders.replaceObjectAtIndex(index, withObject: order)
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  // MARK: - SWTableViewDelegate
  func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
    switch index {
    case 0:
      let indexPath = tableView.indexPathForCell(cell)!
      let order = orders[indexPath.row] as! BookOrder
      orders.removeObjectAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
      let userID = JSHAccountManager.sharedJSHAccountManager().userid
      let token = JSHAccountManager.sharedJSHAccountManager().token
      ZKJSHTTPSessionManager.sharedInstance().deleteOrderWithUserID(userID, token: token, reservation_no: order.reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg("删除失败")
      })
    default:
      break
    }
  }

  // MARK: - Private Method
//  func dismissSelf() -> Void {
//    dismissViewControllerAnimated(true, completion: nil)
//  }
  
  func loadMoreData() -> Void {
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    let page = String(orderPage)
    ZKJSHTTPSessionManager.sharedInstance().getOrderListWithUserID(userID, token: token, page: page, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.tableView.footer.hidden = false
      let orderArray = responseObject as! NSArray
      if orderArray.count != 0 {
        for orderInfo in orderArray {
          let order = BookOrder()
          order.arrival_date = orderInfo["arrival_date"] as? String
          order.created = orderInfo["created"] as? String
          order.departure_date = orderInfo["departure_date"] as? String
          order.guest = orderInfo["guest"] as? String
          order.guesttel = orderInfo["guesttel"] as? String
          order.orderid = orderInfo["id"] as? String
          order.remark = orderInfo["remark"] as? String
          order.reservation_no = orderInfo["reservation_no"] as? String
          order.room_rate = orderInfo["room_rate"] as? String
          order.room_type = orderInfo["room_type"] as? String
          order.room_typeid = orderInfo["room_typeid"] as? String
          order.rooms = orderInfo["rooms"] as? String
          order.shopid = orderInfo["shopid"] as? String
          order.fullname = orderInfo["fullname"] as? String
          order.status = orderInfo["status"] as? String
          order.nologin = orderInfo["nologin"] as? String
          var dateFormatter = NSDateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          let startDate = dateFormatter.dateFromString(order.arrival_date)
          let endDate = dateFormatter.dateFromString(order.departure_date)
          order.dayInt = NSDate.daysFromDate(startDate!, toDate: endDate!)
          self.orders.addObject(order)
        }
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
