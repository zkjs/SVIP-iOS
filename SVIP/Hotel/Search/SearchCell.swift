//
//  SearchCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/20.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "SearchCell"
  }
  
  class func nibName() -> String {
    return "SearchCell"
  }
  
  class func height() -> CGFloat {
    return 45
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
