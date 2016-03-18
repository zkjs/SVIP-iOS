//
//  OrderCell.swift
//  SVIP
//
//  Created by AlexBang on 15/12/8.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderCustomCell: UITableViewCell {

  @IBOutlet weak var hotelnameLaben: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var hotelImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  class func reuseIdentifier() -> String {
    return "OrderCustomCell"
  }
  
  class func nibName() -> String {
    return "OrderCustomCell"
  }
  
  class func height() -> CGFloat {
    return 300
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
