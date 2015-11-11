//
//  OrderListCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/3.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderListCell: SWTableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weeklabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var hotelnameLabel: UILabel!
    @IBOutlet weak var hotelImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
      class func reuseIdentifier() -> String {
        return "OrderListCell"
      }
      
      class func nibName() -> String {
        return "OrderListCell"
      }
      
      class func height() -> CGFloat {
        return 116.0
      }

  func setOrder(order:BookOrder) {
    let hotelUrl = "\(kBaseURL)uploads/shops/\(order.shopid).png"
    hotelImageView.sd_setImageWithURL(NSURL(string: hotelUrl), placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    hotelnameLabel.text = order.fullname
    roomTypeLabel.text = order.room_type + "x" + order.rooms
    priceLabel.text = "￥" + order.room_rate
    getDayOfWeek(order.arrival_date)
    daysFromDateString(order.departure_date, toDateString: order.arrival_date)
    rightUtilityButtons = rightButtons() as [AnyObject]
  }
  
  func getDayOfWeek(today:String) {
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let todayDate = formatter.dateFromString(today)!
    let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
    let weekDay = myComponents.weekday
    weeklabel.text = "周\(weekDay)"
  }

  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }
  
  func daysFromDateString(fromDateString: String, toDateString: String) -> Int {
    let dateFormat = NSDateFormatter()
    guard let fromDate = dateFormat.dateFromString(fromDateString) else { return 0 }
    guard let toDate = dateFormat.dateFromString(toDateString) else { return 0}
    var startingDate: NSDate? = nil
    var resultDate: NSDate? = nil
    let calendar = NSCalendar.currentCalendar()
    calendar.rangeOfUnit(.Day, startDate: &startingDate, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(.Day, startDate: &resultDate, interval: nil, forDate: toDate)
    let dateComponets = calendar.components(.Day, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions())
    dateLabel.text = "还有\(dateComponets.day)"
    print("days\(dateComponets.day)")
    return dateComponets.day
  }

}
