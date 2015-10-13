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
  
  var shopID = ""
  var dateFormatter = NSDateFormatter()
  var roomCount = 1
  var duration = 1
  var roomTypes = NSMutableArray()
  var roomTypeID = ""
  var rooms = ""
  var breakfast = ""
  var startDate = NSDate()
  var endDate = NSDate()
  var roomImageURL = ""
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    roomTypePromptLabel.text = NSLocalizedString("CHOOSE_ROOM_TYPE", comment: "")
    roomCountInfoLabel.text = NSLocalizedString("ROOM_COUNT", comment: "")
    dateInfoLabel.text = NSLocalizedString("START_END_DATE", comment: "")
    sendOrderButton.setTitle(NSLocalizedString("SEND_ORDER", comment: ""), forState: UIControlState.Normal)

    title = NSLocalizedString("FILL_BOOKING_FORM", comment: "")
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""),
                                                             style: UIBarButtonItemStyle.Done,
                                                             target: self,
                                                             action: "gotoChatVC")
    
    dateFormatter.dateFormat = "M-dd"
    startDateLabel.text = dateFormatter.stringFromDate(startDate)
    endDateLabel.text = dateFormatter.stringFromDate(endDate.dateByAddingTimeInterval(60*60*24*1))
    dateTips.text = String(format: NSLocalizedString("DEPARTURE_DATE_PROMPT", comment: ""), arguments: [self.duration, self.endDateLabel.text!])
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
            let url = NSURL(string: baseUrl)
            url?.URLByAppendingPathComponent(goodsImage)
            self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RetryFailed], completed: nil)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func gotoChatVC() {
    let order = BookOrder()
    order.shopid = shopID
    order.rooms = rooms
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
    order.dayInt = String(duration)
    var guests = [String]()
    for index in 0..<roomCount {
      guests.append(nameTextFields[index].text!)
    }
    order.guest = guests.joinWithSeparator(",")
    order.guesttel = JSHStorage.baseInfo().phone
    order.room_image = roomImage.image
    
    let chatVC = JSHChatVC(chatType: .NewSession)
    chatVC.order = order
    chatVC.shopID = shopID
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Action
  
  @IBAction func roomCountChanged(sender: UIStepper) {
    rooms = Int(sender.value).description
    roomCountLabel.text = rooms
    let count = Int(sender.value)
    roomCount = count
    tableView.reloadData()
  }
  
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
    
    if indexPath.section == kRoomSection && indexPath.row == kRoomRow {  // 房型
      let vc = BookVC()
      vc.shopid = shopID
      vc.dataArray = roomTypes
      vc.selection = { [unowned self] (goods: RoomGoods) -> () in
        self.roomType.text = goods.room! + goods.type!
        self.roomTypeID = goods.goodsid!
        self.breakfast = goods.meat!
        self.roomImageURL = goods.image!
        let baseUrl = kBaseURL
        if let goodsImage = goods.image {
          let placeholderImage = UIImage(named: "bg_dingdan")
          let url = NSURL(string: baseUrl)
          url?.URLByAppendingPathComponent(goodsImage)
          self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RetryFailed], completed: nil)
        }
      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == kDateSection && indexPath.row == kDateRow {  // 入住/离店时间
      let vc = BookDateSelectionViewController()
      vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
        self.startDateLabel.text = self.dateFormatter.stringFromDate(startDate)
        self.endDateLabel.text = self.dateFormatter.stringFromDate(endDate)
        self.startDate = startDate
        self.endDate = endDate
        self.duration = NSDate.daysFromDate(startDate, toDate: endDate)
        self.dateTips.text = String(format: NSLocalizedString("DEPARTURE_DATE_PROMPT", comment: ""), arguments: [self.duration, self.endDateLabel.text!])
      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == kNameSection {  // 入住人
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
