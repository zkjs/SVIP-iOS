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
  var emptyLabel = UILabel()
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("ORDRE_LIST", comment: "")
    let cellNib = UINib(nibName: OrderListCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: OrderListCell.reuseIdentifier())
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
    tableView.mj_footer.hidden = true
    tableView.tableFooterView = UIView()
    layoutHidView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    showHUDInView(view, withLoading: "")
    orderPage = 1
    loadMoreData()
  }
  
  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return OrderListCell.height()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: OrderListCell = tableView.dequeueReusableCellWithIdentifier(OrderListCell.reuseIdentifier()) as! OrderListCell
    let order = orders[indexPath.row] as! OrderListModel
    cell.setOrder(order)
    cell.delegate = self
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  func layoutHidView() {
    if orders.count == 0 {
      let screenSize = UIScreen.mainScreen().bounds
      emptyLabel.frame = CGRectMake(0.0, 30, 300.0, 30.0)
      emptyLabel.textAlignment = .Center
      emptyLabel.font = UIFont.systemFontOfSize(14)
      emptyLabel.text = "您还没有订单,有预订时,将会在此查看订单"
      emptyLabel.textColor = UIColor.ZKJS_promptColor()
      emptyLabel.center = CGPointMake(screenSize.midX, screenSize.midY - 60.0)
      emptyLabel.hidden = true
      view.addSubview(emptyLabel)
    }
  }
  
//  //设置cell的显示动画
//  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//    cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
//    UIView.animateWithDuration(0.25) { () -> Void in
//      cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
//    }
//  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let order = orders[indexPath.row] as! OrderListModel
    let index = order.orderno.startIndex.advancedBy(1)
    let type = order.orderno.substringToIndex(index)
    print(type)
    if type == "H" {
      let storyboard = UIStoryboard(name: "HotelOrderDetailTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("HotelOrderDetailTVC") as! HotelOrderDetailTVC
      vc.reservation_no = order.orderno
      self.navigationController?.pushViewController(vc, animated: true)
    }
    if type == "O" {
      let storyboard = UIStoryboard(name: "LeisureOrderDetailTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("LeisureOrderDetailTVC") as! LeisureOrderDetailTVC
      vc.reservation_no = order.orderno
      self.navigationController?.pushViewController(vc, animated: true)
    }
    if type == "K" {
      let storyboard = UIStoryboard(name: "KTVOrderDetailTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("KTVOrderDetailTVC") as! KTVOrderDetailTVC
      vc.reservation_no = order.orderno
      self.navigationController?.pushViewController(vc, animated: true)
    }
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
      let order = orders[indexPath.row] as! OrderListModel
      orders.removeObjectAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      ZKJSHTTPSessionManager.sharedInstance().deleteOrderWithReservationNO(order.orderno, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
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
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderListWithPage(page, size: "10", success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let orderArray = responseObject as! NSArray
      if page == "1" {
        self.orders.removeAllObjects()
      }
          if orderArray.count != 0 {
            for orderInfo in orderArray {
              let order = OrderListModel(dic: orderInfo as! NSDictionary)
              self.orders.addObject(order)
            }
            self.hideHUD()
            self.emptyLabel.hidden = true
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.orderPage++
          } else {
            self.hideHUD()
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
      }
      if self.orders.count == 0 {
            self.emptyLabel.hidden = false
          }
      }) { (task: NSURLSessionDataTask!, error: NSError!)-> Void in
    }
  }
  
}

