//
//  CustonCell.swift
//  SVIP
//
//  Created by AlexBang on 15/12/5.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CustonCell: UITableViewCell {
  var nowDate = NSDate()
  var compareNumber:NSNumber!

  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var orderStatusLabel: UILabel!
  @IBOutlet weak var hotelnameLabel: UILabel!
  @IBOutlet weak var hotelImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  class func reuseIdentifier() -> String {
    return "CustonCell"
  }
  
  class func nibName() -> String {
    return "CustonCell"
  }
  
  class func height() -> CGFloat {
    return 280
  }
  
  func setData(order:BookOrder) {
    
    hotelnameLabel.text = order.fullname
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(nowDate)
        compareNumber = NSNumber(int: ZKJSTool.compareOneDay(order.departure_date, withAnotherDay:dateString ))
    if compareNumber == -1 {
      orderStatusLabel.text = "\(order.room_type!) | \(order.dayInt)晚 | \(order.departureDateShortStyle!) | " + "￥" + order.room_rate.stringValue + "(已过期)"
    } else {
      orderStatusLabel.text = "\(order.room_type!) | \(order.dayInt)晚 | \(order.departureDateShortStyle!) | " + "￥" + order.room_rate.stringValue
    }
    
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
