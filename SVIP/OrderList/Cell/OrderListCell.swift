//
//  OrderListCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/3.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderListCell: UITableViewCell {

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

    
}
