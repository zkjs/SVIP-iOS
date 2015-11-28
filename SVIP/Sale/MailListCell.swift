//
//  MailListCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/28.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MailListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
  
  class func reuseIdentifier() -> String {
    return "MailListCell"
  }
  
  class func nibName() -> String {
    return "MailListCell"
  }
  
  class func height() -> CGFloat {
    return 80
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
