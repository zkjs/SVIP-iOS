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
    title = NSLocalizedString("ORDRE_LIST", comment: "")
    let cellNib = UINib(nibName: OrderListCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: OrderListCell.reuseIdentifier())
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    tableView.mj_footer.hidden = true
    tableView.tableFooterView = UIView()
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
    return OrderListCell.height()
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
    
    let cell: OrderListCell = tableView.dequeueReusableCellWithIdentifier(OrderListCell.reuseIdentifier()) as! OrderListCell
    let order = orders[indexPath.row] as! OrderModel
    cell.setOrder(order)
    cell.delegate = self
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let order = orders[indexPath.row] as! OrderModel
//    if Int(order.status) == 0 {  // 0 未确认可取消订单
//      let bookingOrderDetailVC = BookingOrderDetailVC(order: order)
//      bookingOrderDetailVC.delegate = self
//      navigationController?.pushViewController(bookingOrderDetailVC, animated: true)
//    } else {
//      navigationController?.pushViewController(OrderDetailVC(order: order), animated: true)
//    }
    let storyboard = UIStoryboard(name: "BookingOrderDetail", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderDetailTVC") as! BookingOrderDetailTVC
    vc.reservation_no = order.reservation_no
    navigationController?.pushViewController(vc, animated: true)

    
  }
  
  // MARK: - BookingOrderDetailVCDelegate
  func didCancelOrder(order: BookOrder) {
//    order.status = "1"  // 1 取消订单
//    let index = orders.indexOfObject(order)
//    orders.replaceObjectAtIndex(index, withObject: order)
//    let indexPath = NSIndexPath(forRow: index, inSection: 0)
//    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  // MARK: - SWTableViewDelegate
  func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
    switch index {
    case 0:
      let indexPath = tableView.indexPathForCell(cell)!
      let order = orders[indexPath.row] as! OrderModel
      orders.removeObjectAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
      ZKJSHTTPSessionManager.sharedInstance().deleteOrderWithReservationNO(order.reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          self.showHint(NSLocalizedString("FAILED", comment: ""))
      })
    default:
      break
    }
  }

  // MARK: - Private Method
  
  func loadMoreData() -> Void {
    let page = String(orderPage)
    ZKJSHTTPSessionManager.sharedInstance().getOrderListWithPage(page, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.tableView.mj_footer.hidden = false
      let orderArray = responseObject as! NSArray
      if orderArray.count != 0 {
        for orderInfo in orderArray {
          let order = OrderModel(dic: orderInfo as! NSDictionary)
          self.orders.addObject(order)
        }
        print(self.orders.count)
        self.tableView.reloadData()
        self.tableView.mj_footer.endRefreshing()
        self.orderPage++
      } else {
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
  
}
