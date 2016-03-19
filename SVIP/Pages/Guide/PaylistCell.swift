//
//  PaylistCell.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class PaylistCell: UITableViewCell {

  @IBOutlet weak var moneyPayLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var hotelNamelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  class func reuseIdentifier() -> String {
    return "PaylistCell"
  }

  class func nibName() -> String {
    return "PaylistCell"
  }

  class func height() -> CGFloat {
    return 100
  }

  func setData(pay:PaylistmModel) {
    moneyPayLabel.text = (Double(pay.amount) / 100).format(".2")
    timeLabel.text = pay.createtime
    hotelNamelabel.text = pay.shopname
  }
    
}
