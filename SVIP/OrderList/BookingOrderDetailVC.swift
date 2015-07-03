//
//  BookingOrderDetailVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

protocol BookingOrderDetailVCDelegate {
  func didCancelOrder(order: NSDictionary)
}

class BookingOrderDetailVC: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var dateDurationLabel: UILabel!
  
  let order: NSDictionary
  
  var delegate: BookingOrderDetailVCDelegate? = nil
  
  // MARK: - Init
  init(order: NSDictionary?) {
    self.order = order!
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Lifecycle
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("BookingOrderDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "预定中的订单"
    
    var startDateString = order["arrival_date"] as! String
    var endDateString = order["departure_date"] as! String
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(startDateString)
    let endDate = dateFormatter.dateFromString(endDateString)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    let status = order["status"] as! String
    let room_rate_string = order["room_rate"] as! NSString
    let room_rate = Int(room_rate_string.doubleValue)
    let rooms = order["rooms"] as! String
    let createdDate = order["created"] as! String
    
    nameLabel.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    dateLabel.text = "在 \(createdDate) 预订"
    roomTypeLabel.text = order["room_type"] as? String
    durationLabel.text = "\(days)晚"
    dateFormatter.dateFormat = "M/dd"
    startDateString = dateFormatter.stringFromDate(startDate!)
    endDateString = dateFormatter.stringFromDate(endDate!)
    dateDurationLabel.text = "\(startDateString)-\(endDateString)"
  }
  
  // MARK: - Button Action
  @IBAction func showChatView(sender: AnyObject) {
    navigationController?.pushViewController(JSHChatVC(), animated: true)
  }

  @IBAction func cancelOrder(sender: AnyObject) {
    let userID = "557cff54a9a97"
    let token = "wzWqj5elcC50gosP"
    let orderID = order["id"] as! String
    ZKJSTool.showLoading("正在取消订单...")
    ZKJSHTTPSessionManager.sharedInstance().cancelOrderWithUserID(userID, token: token, orderID: orderID, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      ZKJSTool.hideHUD()
      self.delegate?.didCancelOrder(self.order)
      self.navigationController?.popToRootViewControllerAnimated(true)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      ZKJSTool.hideHUD()
      ZKJSTool.showMsg(error.description)
    }
  }
  
}
