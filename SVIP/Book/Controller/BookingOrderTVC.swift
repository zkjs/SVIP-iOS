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
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsetsMake(-36.0, 0.0, 0.0, 0.0)
    
    roomTypePromptLabel.text = NSLocalizedString("CHOOSE_ROOM_TYPE", comment: "")
    roomCountInfoLabel.text = NSLocalizedString("ROOM_COUNT", comment: "")
    dateInfoLabel.text = NSLocalizedString("START_END_DATE", comment: "")
    sendOrderButton.setTitle(NSLocalizedString("SEND_ORDER", comment: ""), forState: UIControlState.Normal)

    title = NSLocalizedString("FILL_BOOKING_FORM", comment: "")
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""),
//                                                             style: UIBarButtonItemStyle.Done,
//                                                             target: self,
//                                                             action: "gotoChatVC")
    
    dateFormatter.dateFormat = "M-dd"
    startDateLabel.text = dateFormatter.stringFromDate(startDate)
    endDateLabel.text = dateFormatter.stringFromDate(endDate)
    dateFormatter.dateFormat = "M月d日"
    dateTips.text = String(format: NSLocalizedString("DEPARTURE_DATE_PROMPT", comment: ""), arguments: [self.duration, dateFormatter.stringFromDate(endDate)])
    rooms = "1"
    
    loadRoomTypes()
  }
  
  // MARK: - Private
  
  func loadRoomTypes() {
    ZKJSHTTPSessionManager.sharedInstance().getShopGoodsListWithShopID(shopID, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let arr = responseObject as? NSArray {
        for dict in arr {
          if let myDict = dict as? NSDictionary {
            let goods = RoomGoods(dic: myDict)
            self.roomTypes.addObject(goods)
          }
        }
        // 默认房型, 图片
        if let defaultGoods = self.roomTypes.firstObject as? RoomGoods {
          self.roomType.text = defaultGoods.room! + defaultGoods.type!
          self.roomTypeID = defaultGoods.goodsid!
          self.breakfast = defaultGoods.meat!
          self.roomImageURL = defaultGoods.image!
          let baseUrl = kBaseURL
          if let goodsImage = defaultGoods.image {
            let placeholderImage = UIImage(named: "bg_dingdan")
            var url = NSURL(string: baseUrl)
            url = url?.URLByAppendingPathComponent(goodsImage)
            self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [.LowPriority, .RetryFailed], completed: nil)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func gotoChatVC() {
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(shopID, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      self.chooseChatterWithData(responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
    let order = packetOrder()
    vc.title = order.fullname
    // 扩展字段
    let userName = JSHStorage.baseInfo().username
    let ext = ["shopId": order.shopid.stringValue,
    "shopName": order.fullname,
    "toName": salesName,
    "fromName": userName]
    vc.conversation.ext = ext
    vc.firstMessage = "Card"
    vc.order = order
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func packetOrder() -> BookOrder {
    let order = BookOrder()
    order.shopid = NSNumber(integer: Int(shopID)!)
    order.rooms = NSNumber(integer: Int(rooms)!)
    order.room_typeid = roomTypeID
    order.room_type = roomType.text! + breakfast
    if let shopName = StorageManager.sharedInstance().shopNameWithShopID(shopID) {
      order.fullname = shopName
    }
    order.room_image_URL = roomImageURL
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    order.arrival_date = dateFormatter.stringFromDate(startDate)
    order.departure_date = dateFormatter.stringFromDate(endDate)
    var guests = [String]()
    for index in 0..<roomCount {
      guests.append(nameTextFields[index].text!)
    }
    order.guest = guests.joinWithSeparator(",")
    order.guesttel = JSHStorage.baseInfo().phone
    order.room_image = roomImage.image
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
//      if indexPath.row > roomCount {
        return 0.0
//      }
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
    print(indexPath)
    
    if indexPath.section == kRoomSection && indexPath.row == kRoomRow {
      // 房型
      let vc = BookVC()
      vc.shopid = NSNumber(integer: Int(shopID)!)
      vc.dataArray = roomTypes
      vc.selection = { [unowned self] (goods: RoomGoods) -> () in
        self.roomType.text = goods.room! + goods.type!
        self.roomTypeID = goods.goodsid!
        self.breakfast = goods.meat!
        self.roomImageURL = goods.image!
        let baseUrl = kBaseURL
        if let goodsImage = goods.image {
          let placeholderImage = UIImage(named: "bg_dingdan")
          var url = NSURL(string: baseUrl)
          url = url?.URLByAppendingPathComponent(goodsImage)
          self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [.LowPriority, .RetryFailed], completed: nil)
        }
      }
      navigationController?.pushViewController(vc, animated: true)
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
