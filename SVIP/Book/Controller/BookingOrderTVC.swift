//
//  BookingOrderTVC.swift
//  SVIP
//
//  Created by Hanton on 8/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kNameSection = 2

class BookingOrderTVC: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var roomType: UILabel!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet weak var dateTips: UILabel!
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  
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

    title = "填写订单"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoChatVC")
    
    dateFormatter.dateFormat = "M月dd日"
    startDateLabel.text = dateFormatter.stringFromDate(startDate)
    endDateLabel.text = dateFormatter.stringFromDate(endDate.dateByAddingTimeInterval(60*60*24*1))
    dateTips.text = "共\(duration)晚，在\(endDateLabel.text!)13点前退房"
    rooms = "1"
    
    loadRoomTypes()
  }
  
  // MARK: - Private
  
  func loadRoomTypes() {
    ZKJSHTTPSessionManager .sharedInstance() .getShopGoodsWithShopID(shopID, page: 1, categoryID: nil, key: nil, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
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
            let urlStr = baseUrl .stringByAppendingString(goodsImage)
            let placeholderImage = UIImage(named: "bg_dingdan")
            let url = NSURL(string: urlStr)
            self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
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
    let shopsInfo = StorageManager.sharedInstance().shopsInfo()
    let predicate = NSPredicate(format: "shopid = %@", shopID)
    let shopInfo = shopsInfo?.filteredArrayUsingPredicate(predicate).first as! NSDictionary
    if let shopName = shopInfo["fullname"] as? String {
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
      guests.append(nameTextFields[index].text)
    }
    order.guest = ",".join(guests)
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
    roomCountLabel.text = rooms + "间"
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
      if indexPath.row > roomCount {
        return 0.0
      }
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = super.tableView(tableView, numberOfRowsInSection: section)
    if section == kNameSection {
      count = roomCount
    }
    return count
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
    
    if indexPath.section == 0 && indexPath.row == 0 {  // 房型
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
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "bg_dingdan")
          let url = NSURL(string: urlStr)
          self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }
      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == 1 && indexPath.row == 1 {  // 入住/离店时间
      let vc = BookDateSelectionViewController()
      vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
        self.startDateLabel.text = self.dateFormatter.stringFromDate(startDate)
        self.endDateLabel.text = self.dateFormatter.stringFromDate(endDate)
        self.startDate = startDate
        self.endDate = endDate
        self.duration = NSDate.daysFromDate(startDate, toDate: endDate)
        self.dateTips.text = "共\(self.duration)晚，在\(self.endDateLabel.text!)13点前退房"
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
