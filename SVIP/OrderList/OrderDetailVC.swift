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
  @IBOutlet weak var chatButton: UIButton!
  @IBOutlet weak var bookingInfoLabel: UILabel!
  @IBOutlet weak var roomInfoLabel: UILabel!
  @IBOutlet weak var billInfoLabel: UILabel!
  
  var order: BookOrder
  
  // MARK: - Init
  init(order: BookOrder?) {
    self.order = order!
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Lifecycle
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("OrderDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = NSLocalizedString("ORDER_DETAIL", comment: "")
    bookingInfoLabel.text = NSLocalizedString("BOOKING_INFO", comment: "")
    roomInfoLabel.text = NSLocalizedString("ROOM_INFO", comment: "")
    billInfoLabel.text = NSLocalizedString("BILL_INFO", comment: "")
    chatButton.setTitle(NSLocalizedString("IN_ROOM_CHECK_IN", comment: ""), forState: UIControlState.Normal)
    
    setupChatButton()
    
    // 把Navigation Bar设置为不透明的
    navigationController?.navigationBar.barStyle = .Default
    navigationController?.navigationBar.translucent = false
    
    var startDateString = order.arrival_date
    var endDateString = order.departure_date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(startDateString)
    let endDate = dateFormatter.dateFromString(endDateString)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    var room_rate = 0
    if let roomRate = Int(order.room_rate) {
      room_rate = roomRate
    }
    let rooms = order.rooms
    let createdDate = order.created

    nameLabel.text = order.fullname
    dateLabel.text = String(format: NSLocalizedString("BOOKING_AT", comment: ""), arguments: [createdDate])
    roomTypeLabel.text = order.room_type
    durationLabel.text = "\(days) " + NSLocalizedString("NIGHT", comment: "")
    dateFormatter.dateFormat = "M/dd"
    startDateString = dateFormatter.stringFromDate(startDate!)
    endDateString = dateFormatter.stringFromDate(endDate!)
    dateDurationLabel.text = "\(startDateString)-\(endDateString)"
    amountFormulaLabel.text = "¥\(room_rate) * \(Int(rooms)!)" + NSLocalizedString("ROOM", comment: "") + " * \(days)" + NSLocalizedString("NIGHT", comment: "")
    amountLabel.text = "¥\(room_rate * Int(rooms)! * days)"
  }
  
  // MARK: - Button Action
  @IBAction func showChatView(sender: AnyObject) {
    let chatVC = JSHChatVC(chatType: .OldSession)
    chatVC.shopID = order.shopid
    chatVC.shopName = order.fullname
    chatVC.firstMessage = NSLocalizedString("FIRST_MESSAGE_IN_ROOM_CHECK_IN", comment: "")
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Private Method
  
  func setupChatButton() {
    chatButton.layer.borderWidth = 0.6
    chatButton.layer.borderColor = UIColor.blackColor().CGColor
    chatButton.layer.cornerRadius = 6
    chatButton.layer.masksToBounds = true
  }
}
