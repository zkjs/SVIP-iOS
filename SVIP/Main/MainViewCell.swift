
//  MainViewCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainViewCell: UITableViewCell{
   var nowDate = NSDate()
  var compareNumber:NSNumber!
  @IBOutlet weak var orderStyleLabel: UILabel!
  @IBOutlet weak var orderStatusLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var hotelImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  class func reuseIdentifier() -> String {
    return "MainViewCell"
  }
  
  class func nibName() -> String {
    return "MainViewCell"
  }
  
  class func height() -> CGFloat {
    return 150
  }
  
  func setData(order:BookOrder) {
    orderStyleLabel.text = "\(order.room_type!) | \(order.dayInt)晚 | \(order.departureDateShortStyle!) | " + "￥" + order.room_rate.stringValue
    hotelNameLabel.text = order.fullname
    let url = NSURL(string: kBaseURL)
    let urlStr = url?.URLByAppendingPathComponent("uploads/shops/\(order.shopid).png")
    hotelImageView.sd_setImageWithURL(urlStr, placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    //判断订单的状态
    let beacon = StorageManager.sharedInstance().lastBeacon()
    let order = StorageManager.sharedInstance().lastOrder()
    let state = order?.status
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.stringFromDate(nowDate)
   compareNumber = NSNumber(int: ZKJSTool.compareOneDay(order?.departure_date, withAnotherDay:dateString ))
    
    if beacon != nil && order != nil {
      if compareNumber == 1 {
        orderStatusLabel.text = " 您的订单已确定，请及时办理入住手续"
      }
      if compareNumber == -1 {
        
      }
      if compareNumber == 0 && state == 4 {
        orderStatusLabel.text = "\(order?.fullname)随时为您服务"
      }

    }
    if order != nil && beacon == nil {
      if compareNumber == 1 && state == 0 {
        orderStatusLabel.text = " \(order!.dayInt)天后入住 \(order!.fullname)"
      }
      if compareNumber == -1 {
        orderStatusLabel.text = "您没有任何订单 立即预定"
      }
      if compareNumber == 0  && state == 4 {
        orderStatusLabel.text = "随时为您服务"
      }
      
    }
    if order == nil && beacon != nil {
      orderStatusLabel.text = "\(order!.fullname)欢迎您"
    }
    if order == nil && beacon == nil {
      orderStatusLabel.text = "您没有任何预定信息 立即预定"
    }
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
