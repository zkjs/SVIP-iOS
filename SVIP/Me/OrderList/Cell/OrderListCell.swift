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
  @IBOutlet weak var statsLabel: UILabel! {
    didSet {
      statsLabel.layer.cornerRadius = 10
      statsLabel.layer.borderWidth = 1
      statsLabel.layer.borderColor = UIColor.ZKJS_whiteColor().CGColor
      statsLabel.layer.masksToBounds = true
    }
  }
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

  func setOrder(order:OrderListModel) {
    let hotelUrl = "\(kBaseURL)uploads/shops/\(order.shopid).png"
    hotelImageView.sd_setImageWithURL(NSURL(string: hotelUrl), placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    hotelnameLabel.text = order.shopname
    roomTypeLabel.text = order.roomtype! + "x" + (order.roomcount?.stringValue)!
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    locationLabel.text = dateFormatter.stringFromDate(order.created)
    
    priceLabel.text =   " ￥\(order.roomprice)"
    rightUtilityButtons = rightButtons() as [AnyObject]
    setupStatsLabel(order)
  }
  
  func setupStatsLabel(order:OrderListModel) {
    statsLabel.backgroundColor = UIColor.ZKJS_mainColor()
    statsLabel.text = order.orderstatus
    
  }
//  func getDayOfWeek(today:String) {
//    let formatter = NSDateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//    let todayDate = formatter.dateFromString(today)!
//    let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//    let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
//    let weekDay = myComponents.weekday
//    weeklabel.text = "周\(weekDay)"
//  }

  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }
  
//  func daysFromDateString(fromDateString: String, toDateString: String) -> Int {
//    let dateFormat = NSDateFormatter()
//    guard let fromDate = dateFormat.dateFromString(fromDateString) else { return 0 }
//    guard let toDate = dateFormat.dateFromString(toDateString) else { return 0}
//    var startingDate: NSDate? = nil
//    var resultDate: NSDate? = nil
//    let calendar = NSCalendar.currentCalendar()
//    calendar.rangeOfUnit(.Day, startDate: &startingDate, interval: nil, forDate: fromDate)
//    calendar.rangeOfUnit(.Day, startDate: &resultDate, interval: nil, forDate: toDate)
//    let dateComponets = calendar.components(.Day, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions())
//    dateLabel.text = "还有\(dateComponets.day)"
//    print("days\(dateComponets.day)")
//    return dateComponets.day
//  }

}
