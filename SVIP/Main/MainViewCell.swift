//
//  MainViewCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainViewCell: UITableViewCell {

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
    return 130
  }
  func setData(order:BookOrder) {
    orderStyleLabel.text = "\(order.room_type!) | \(order.dayInt!)晚 | \(order.arrival_date!) | \("￥" + order.room_rate)"
    hotelNameLabel.text = order.fullname
    let url = NSURL(string: kBaseURL)
    let urlStr = url?.URLByAppendingPathComponent("uploads/shops/\(order.shopid).png")
    hotelImageView.sd_setImageWithURL(urlStr, placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
