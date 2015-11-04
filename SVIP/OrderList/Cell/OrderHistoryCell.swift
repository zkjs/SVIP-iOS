//
//  OrderHistoryCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/3.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderHistoryCell: UITableViewCell {

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
  

    
}
