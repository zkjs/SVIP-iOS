//
//  Orderswift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kCellReuseId = "OrderCellReuseId"
private let kOrderCell = "OrderCell"

class OrderCell: SWTableViewCell {
  
  @IBOutlet weak var bookingImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!

  class func reuseIdentifier() -> String {
    return kCellReuseId
  }
  
  class func nibName() -> String {
    return kOrderCell
  }
  
  class func height() -> CGFloat {
    return 116.0
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.selectionStyle = .None
  }
  
  func setOrder(order: BookOrder) {
    let urlString = "\(kBaseURL)uploads/shops/\(order.shopid).png"
    let logoURL = NSURL(string: urlString)
    let placeholderImage = UIImage(named: "img_hotel_zhanwei")
    logoImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage, options: [SDWebImageOptions.ProgressiveDownload, SDWebImageOptions.RetryFailed], completed: nil)
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.dateFromString(order.arrival_date)
    let endDate = dateFormatter.dateFromString(order.departure_date)
    let days = NSDate.daysFromDate(startDate!, toDate: endDate!)
    let status = order.status
    var room_rate = 0
    if let roomRate = order.room_rate {
      room_rate = Int((roomRate as NSString).floatValue)
    }
    
    // status=订单状态 默认0 未确认可取消订单 1取消订单 2已确认订单 3已经完成的订单 4已经入住的订单 5删除订单
    if Int(status) == 0 {
      rightUtilityButtons = nil
      bookingImageView.hidden = false
      statusLabel.text = "未确定"
    } else if Int(status) == 1 {
      rightUtilityButtons = rightButtons() as [AnyObject]
      bookingImageView.hidden = true
      statusLabel.text = "已取消"
    } else if Int(status) == 2 {
      rightUtilityButtons = nil
      bookingImageView.hidden = false
      statusLabel.text = "已确定"
    } else if Int(status) == 3 {
      rightUtilityButtons = rightButtons() as [AnyObject]
      bookingImageView.hidden = true
      statusLabel.text = "已完成"
    } else if Int(status) == 4 {
      rightUtilityButtons = nil
      bookingImageView.hidden = false
      statusLabel.text = "已入住"
    }
    
    amountLabel.hidden = false
    amountLabel.text = "¥\(room_rate)"
    
    dateFormatter.dateFormat = "yyyy/MM/dd"
    dateLabel.text = dateFormatter.stringFromDate(startDate!)
    nameLabel.text = order.fullname
    countLabel.text = "\(days)晚"
  }
  
  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }
  
}
