//
//  BookingOrderTVC.swift
//  SVIP
//
//  Created by Hanton on 8/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kRoomSection = 0
private let kRoomRow = 0
private let kRoomCountRow = 1
private let kDateSection = 1
private let kDateRow = 1
private let kNameSection = 2

class BookingOrderTVC: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var roomPriceLabel: UILabel!
  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var roomType: UILabel!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet weak var dateTips: UILabel!
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  
  @IBOutlet weak var roomTypePromptLabel: UILabel!
  @IBOutlet weak var roomCountInfoLabel: UILabel!
  @IBOutlet weak var dateInfoLabel: UILabel!
  @IBOutlet weak var sendOrderButton: UIButton!
  var shopName = String()
  var shopID = String()
  var dateFormatter = NSDateFormatter()
  var roomCount = 1
  var duration = 1
  var roomTypes = NSMutableArray()
  var roomTypeID = ""
  var rooms = ""
  var breakfast = ""
  var startDate = NSDate()
  var endDate = NSDate().dateByAddingTimeInterval(60*60*24*1)
  var roomImageURL = ""
  var goods = RoomGoods!()
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsetsMake(-30, 0.0, 0.0, 0.0)
    roomCountInfoLabel.text = NSLocalizedString("ROOM_COUNT", comment: "")
    dateInfoLabel.text = NSLocalizedString("START_END_DATE", comment: "")
    sendOrderButton.setTitle(NSLocalizedString("SEND_ORDER", comment: ""), forState: UIControlState.Normal)
    title = NSLocalizedString("FILL_BOOKING_FORM", comment: "")
    dateFormatter.dateFormat = "M-dd"
    startDateLabel.text = dateFormatter.stringFromDate(startDate)
    endDateLabel.text = dateFormatter.stringFromDate(endDate)
    dateFormatter.dateFormat = "M月d日"
    dateTips.text = String(format: NSLocalizedString("DEPARTURE_DATE_PROMPT", comment: ""), arguments: [self.duration, dateFormatter.stringFromDate(endDate)])
    rooms = "1"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    roomType.text = goods.type
    let baseUrl = kBaseURL
    let placeholderImage = UIImage(named: "星空中心")
    var url = NSURL(string: baseUrl)
    url = url?.URLByAppendingPathComponent(goods.image!)
    print(url)
    roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage)
    roomPriceLabel.text = "￥" + goods.price!
  }
  
  func gotoChatVC() {
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(shopID, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      self.chooseChatterWithData(responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
//    let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
//    let order = packetOrder()
//    print(order)
//    vc.title = order.fullname
//    // 扩展字段
//    let userName = AccountManager.sharedInstance().userName
//    let ext = ["shopId": order.shopid.stringValue,
//    "shopName": order.fullname,
//    "toName": salesName,
//    "fromName": userName]
//    vc.conversation.ext = ext
//    vc.firstMessage = "Card"
//    vc.order = order
//    navigationController?.pushViewController(vc, animated: true)
  }
  
  func packetOrderWithOrderNO(orderNO: String) -> BookOrder {
    let order = BookOrder()
//    order.roomtype = ""
//    order.arrivaldate = arrivaldate
//    order.leavedate = leavedate
//    order.imgurl = goods.image
//    order.orderno = orderNO
//    order.orderstatus = "待处理"
    return order
  }
  
  func chooseChatterWithData(data: AnyObject) {
    if let head = data["head"] as? [String: AnyObject] {
      if let set = head["set"] as? NSNumber {
        if set.boolValue {
          if let exclusive_salesid = head["exclusive_salesid"] as? String {
            if let data = data["data"] as? [[String: AnyObject]] {
              for sale in data {
                if let salesid = sale["salesid"] as? String {
                  if salesid == exclusive_salesid {
                    if let name = sale["name"] as? String {
                      self.createConversationWithSalesID(salesid, salesName: name)
                    }
                  }
                }
              }
            }
          } else if let data = data["data"] as? [[String: AnyObject]] where data.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(data.count)))
            let sale = data[randomIndex]
            if let salesid = sale["salesid"] as? String,
              let name = sale["name"] as? String {
                self.createConversationWithSalesID(salesid, salesName: name)
            }
          }
        }
      }
    }
  }
  
  func chooseRoomCount() {
    let alertView = UIAlertController(title: "选择房间数", message: "", preferredStyle: .ActionSheet)
    for i in 1...3 {
      alertView.addAction(UIAlertAction(title: "\(i)间", style: .Default, handler: { [unowned self] (action: UIAlertAction!) -> Void in
        self.rooms = "\(i)"
        self.roomCountLabel.text = self.rooms
        self.roomCount = i
        }))
    }
    alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  // MARK: - Action
  
  @IBAction func sendBookingOrder(sender: AnyObject) {
    gotoChatVC()
  }
  
  // MARK: - Table view datasource
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == kNameSection {
        return 0.0
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = super.tableView(tableView, numberOfRowsInSection: section)
    if section == kNameSection {
      count = 0//roomCount
    }
    return count
  }
  
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if indexPath.section == kRoomSection && indexPath.row == kRoomRow {
      navigationController?.popViewControllerAnimated(true)
    } else if indexPath.section == kRoomSection && indexPath.row == kRoomCountRow {
      // 房间数量
      chooseRoomCount()
    } else if indexPath.section == kDateSection && indexPath.row == kDateRow {
      // 入住/离店时间
      let vc = BookDateSelectionViewController()
      vc.startDate = startDate
      vc.endDate = endDate
      vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
        self.startDateLabel.text = self.dateFormatter.stringFromDate(startDate)
        self.endDateLabel.text = self.dateFormatter.stringFromDate(endDate)
        self.startDate = startDate
        self.endDate = endDate
        self.duration = NSDate.daysFromDate(startDate, toDate: endDate)
        self.dateTips.text = String(format: NSLocalizedString("DEPARTURE_DATE_PROMPT", comment: ""), arguments: [self.duration, self.endDateLabel.text!])
      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == kNameSection {
      // 入住人
      let vc = NameTVC()
      vc.selection = { [unowned self] (name: String, idInt: Int) ->() in
        self.nameTextFields[indexPath.row].text = name
      }
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
