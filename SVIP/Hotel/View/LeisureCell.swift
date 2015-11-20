//
//  LeisureCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/16.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LeisureCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  class func reuseIdentifier() -> String {
    return "LeisureCell"
  
  }
  class func nibName() -> String {
    return "LeisureCell"
  }
  class func height() -> CGFloat {
    return 180
  }
  

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
