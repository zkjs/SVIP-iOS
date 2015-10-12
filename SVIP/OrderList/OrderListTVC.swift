//
//  OrderListTVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import Foundation

class OrderListTVC: UITableViewController, SWTableViewCellDelegate, BookingOrderDetailVCDelegate {
  
  var orders: NSMutableArray = []
  var orderPage = 1

  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadMoreData()
    
    title = "订单列表"
    
    let cellNib = UINib(nibName: OrderCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: OrderCell.reuseIdentifier())
    tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    tableView.footer.hidden = true
    tableView.separatorStyle = .None
    tableView.contentInset = UIEdgeInsets(top: -OrderListHeaderView.height(), left: 0.0, bottom: 0.0, right: 0.0)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.hidesBarsOnSwipe = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.hidesBarsOnSwipe = false
  }
  
  // MARK: - Table view data source
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
    return OrderListHeaderView.view()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if orders.count == 0 {
      return UITableViewCell()
    }
    
    let cell: OrderCell = tableView.dequeueReusableCellWithIdentifier(OrderCell.reuseIdentifier()) as! OrderCell
    let order = orders[indexPath.row] as! BookOrder
    cell.setOrder(order)
    cell.delegate = self
    
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let order = orders[indexPath.row] as! BookOrder
    
    if Int(order.status) == 0 {  // 0 未确认可取消订单
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
  
  func loadMoreData() -> Void {
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    let page = String(orderPage)
    ZKJSHTTPSessionManager.sharedInstance().getOrderListWithUserID(userID, token: token, page: page, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.tableView.footer.hidden = false
      let orderArray = responseObject as! NSArray
      if orderArray.count != 0 {
        for orderInfo in orderArray {
          let order = BookOrder(dictionary: orderInfo as! NSDictionary)
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
  
}
