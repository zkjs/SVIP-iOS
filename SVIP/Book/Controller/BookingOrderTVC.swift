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
  @IBOutlet weak var startDate: UILabel!
  @IBOutlet weak var endDate: UILabel!
  @IBOutlet weak var dateTips: UILabel!
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  
  var shopID = ""
  var dateFormatter = NSDateFormatter()
  var roomCount = 1
  var duration = 1
  var roomTypes = NSMutableArray()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "填写订单"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoChatVC")
    
    dateFormatter.dateFormat = "M月dd日"
    startDate.text = dateFormatter.stringFromDate(NSDate())
    endDate.text = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24*1))
    dateTips.text = "共\(duration)晚，在\(endDate.text!)13点前退房"
    
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
    order.rooms = roomCountLabel.text
    order.room_type = roomType.text
    order.arrival_date = startDate.text
    order.departure_date = endDate.text
    order.dayInt = String(duration)
    var guests = [String]()
    for index in 0..<roomCount {
      guests.append(nameTextFields[index].text)
    }
    order.guest = ",".join(guests)
    order.room_image = roomImage.image
    let chatVC = JSHChatVC(chatType: .NewSession)
    chatVC.order = order
    chatVC.shopID = shopID
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Action
  
  @IBAction func roomCountChanged(sender: UIStepper) {
    roomCountLabel.text = Int(sender.value).description + "间"
    let count = Int(sender.value)
    roomCount = count
    tableView.reloadData()
  }
  
  @IBAction func sendBookingOrder(sender: AnyObject) {
    // 还差后台接口发个消息给商家端
    for index in 0..<roomCount {
      println(nameTextFields[index].text)
    }
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
        self.startDate.text = self.dateFormatter.stringFromDate(startDate)
        self.endDate.text = self.dateFormatter.stringFromDate(endDate)
        self.duration = NSDate.daysFromDate(startDate, toDate: endDate)
        self.dateTips.text = "共\(self.duration)晚，在\(self.endDate.text!)13点前退房"
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
