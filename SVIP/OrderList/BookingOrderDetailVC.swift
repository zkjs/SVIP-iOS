//
//  BookingOrderDetailVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

protocol BookingOrderDetailVCDelegate {
  func didCancelOrder(order: BookOrder)
}

class BookingOrderDetailVC: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var dateDurationLabel: UILabel!
  @IBOutlet weak var remarkLabel: UILabel!
  @IBOutlet weak var chatButton: UIButton!
  @IBOutlet weak var paymentButton: UIButton!
  @IBOutlet weak var bookingInfoLabel: UILabel!
  @IBOutlet weak var roomInfoLabel: UILabel!
  @IBOutlet weak var preferredInfoLabel: UILabel!
  @IBOutlet weak var cancelBookingButton: UIButton!
  
  let order: BookOrder
  
  var tagView = SKTagView()
  var delegate: BookingOrderDetailVCDelegate? = nil
  
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
    NSBundle.mainBundle().loadNibNamed("BookingOrderDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = NSLocalizedString("BOOKING_ORDER", comment: "")
    bookingInfoLabel.text = NSLocalizedString("BOOKING_INFO", comment: "")
    roomInfoLabel.text = NSLocalizedString("ROOM_INFO", comment: "")
    preferredInfoLabel.text = NSLocalizedString("PREFERRED", comment: "")
    paymentButton.setTitle(NSLocalizedString("PAYMENT", comment: ""), forState: UIControlState.Normal)
    chatButton.setTitle(NSLocalizedString("IN_ROOM_CHECK_IN", comment: ""), forState: UIControlState.Normal)
    cancelBookingButton.setTitle(NSLocalizedString("CANCEL_BOOKING", comment: ""), forState: UIControlState.Normal)
    
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
    let createdDate = order.created
    
    nameLabel.text = order.fullname
    dateLabel.text = "在 \(createdDate) 预订"
    roomTypeLabel.text = order.room_type
    durationLabel.text = "\(days)晚"
    dateFormatter.dateFormat = "M/dd"
    startDateString = dateFormatter.stringFromDate(startDate!)
    endDateString = dateFormatter.stringFromDate(endDate!)
    dateDurationLabel.text = "\(startDateString)-\(endDateString)"
    
    let remark = order.remark ?? ""
    if !remark.isEmpty {
      let tags = remark.componentsSeparatedByString(",")
      setupTagView(tags)
    }
    
    setupChatButton()
    setupPaymentButton()
  }
  
  // MARK: - Private Method
  
  func setupTagView(tags: [String]) {
    tagView.backgroundColor = UIColor(hexString: "F4F4F3")
    tagView.translatesAutoresizingMaskIntoConstraints = false
    tagView.padding = UIEdgeInsetsMake(8.0, 30.0, 8.0, 30.0)
    tagView.insets = 25
    tagView.lineSpace = 10
    view.addSubview(tagView)
    tagView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
      let superView = self.view
      make.top.equalTo()(self.remarkLabel.mas_bottom)
      make.leading.equalTo()(superView.mas_leading)
      make.trailing.equalTo()(superView.mas_trailing)
    }
    
    for tag in tags {
      let tagButton = SKTag(text: tag)
      tagButton.textColor = UIColor.blackColor()
      tagButton.fontSize = 15
      tagButton.padding = UIEdgeInsetsMake(8, 8, 8, 8)
      tagButton.bgColor = UIColor(hexString: "F4F4F3")
      tagButton.borderColor = UIColor.grayColor()
      tagButton.borderWidth = 0.5
      tagButton.cornerRadius = 6
      tagView.addTag(tagButton)
    }
  }
  
  func setupChatButton() {
    chatButton.layer.borderWidth = 0.6
    chatButton.layer.borderColor = UIColor.blackColor().CGColor
    chatButton.layer.cornerRadius = 6
    chatButton.layer.masksToBounds = true
  }
  
  func setupPaymentButton() {
    paymentButton.layer.borderWidth = 0.6
    paymentButton.layer.borderColor = UIColor.blackColor().CGColor
    paymentButton.layer.cornerRadius = 6
    paymentButton.layer.masksToBounds = true
  }
  
  // MARK: - Button Action
  @IBAction func showChatView(sender: AnyObject) {
    let chatVC = JSHChatVC(chatType: .OldSession)
    chatVC.shopID = order.shopid
    chatVC.shopName = order.fullname
    chatVC.firtMessage = "你好，我想选择快捷入住"
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  @IBAction func payBookingOrder(sender: AnyObject) {
    let payVC = BookPayVC()
    payVC.bkOrder = order
    self.navigationController? .pushViewController(payVC, animated: true)
  }

  @IBAction func cancelOrder(sender: AnyObject) {
    let chatVC = JSHChatVC(chatType: .CancelOrder)
    chatVC.shopID = order.shopid
    chatVC.shopName = order.fullname
    chatVC.firtMessage = "你好，我想取消订单"
    navigationController?.pushViewController(chatVC, animated: true)
    
//    let userID = JSHAccountManager.sharedJSHAccountManager().userid
//    let token = JSHAccountManager.sharedJSHAccountManager().token
//    ZKJSTool.showLoading("正在取消订单...")
//    ZKJSHTTPSessionManager.sharedInstance().cancelOrderWithUserID(userID, token: token, reservation_no: order.reservation_no, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
////      ZKJSTool.hideHUD()
//      ZKJSTool.showMsg("已成功取消订单")
//      
//      let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//        Int64(1 * Double(NSEC_PER_SEC)))
//      dispatch_after(delayTime, dispatch_get_main_queue()) {
//        self.delegate?.didCancelOrder(self.order)
////        if self.navigationController?.viewControllers.first is BookingOrderDetailVC {
////          self.dismissSelf()
////        } else {
//          self.navigationController?.popViewControllerAnimated(true)
////        }
//      }
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//      ZKJSTool.hideHUD()
//      ZKJSTool.showMsg(error.description)
//    }
  }
  
}
