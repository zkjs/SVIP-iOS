//
//  OrderDetailVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailVC: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var dateDurationLabel: UILabel!
  @IBOutlet weak var amountFormulaLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  let order: BookOrder
  
  // MARK: - Init
  init(order: BookOrder?) {
    self.order = order!
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Lifecycle
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("OrderDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "订单详情"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissSelf")
    
    var startDateString = order.arrival_date
    var endDateString = order.departure_date
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(startDateString)
    let endDate = dateFormatter.dateFromString(endDateString)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    let status = order.status
    var room_rate = 0
    if let roomRate = order.room_rate.toInt() {
      room_rate = roomRate
    }
    let rooms = order.rooms
    let createdDate = order.created

    nameLabel.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    dateLabel.text = "在 \(createdDate) 预订"
    roomTypeLabel.text = order.room_type
    durationLabel.text = "\(days)晚"
    dateFormatter.dateFormat = "M/dd"
    startDateString = dateFormatter.stringFromDate(startDate!)
    endDateString = dateFormatter.stringFromDate(endDate!)
    dateDurationLabel.text = "\(startDateString)-\(endDateString)"
    amountFormulaLabel.text = "¥\(room_rate) * \(rooms.toInt()!)间 * \(days)天"
    amountLabel.text = "¥\(room_rate * rooms.toInt()! * days)"
  }
  
  // MARK: - Private Method
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
