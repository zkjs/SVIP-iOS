//
//  OrderHistoryCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/3.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderHistoryCell: SWTableViewCell {

  @IBOutlet weak var roomPriceLabel: UILabel!
  @IBOutlet weak var evaluateLabel: UILabel!
  @IBOutlet weak var creattimeLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var hotelnameLabel: UILabel!
  @IBOutlet weak var hotelImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  class func reuseIdentifier() -> String {
    return "OrderHistoryCell"
  }
  
  class func nibName() -> String {
    return "OrderHistoryCell"
  }
  
  class func height() -> CGFloat {
    return 116.0
  }
  
  func setOrder(order:OrderModel) {
    rightUtilityButtons = rightButtons() as [AnyObject]
    hotelnameLabel.text = order.fullname
    roomTypeLabel.text = order.room_type + "x" + order.rooms.stringValue
    creattimeLabel.text = order.created
    roomPriceLabel.text = "￥" + order.room_rate.stringValue
    if order.score.stringValue == "0" {
      evaluateLabel.text = "未评价"
    }else {
      evaluateLabel.text = order.score.stringValue
    }
    
    
  }
  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }

    
}
