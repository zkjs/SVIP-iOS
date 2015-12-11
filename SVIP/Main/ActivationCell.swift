//
//  ActivationCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/14.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class ActivationCell: UITableViewCell {
  
  @IBOutlet weak var VIPStatusLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  class func reuseIdentifier() -> String {
    return "ActivationCell"
  }
  
  class func nibName() -> String {
    return "ActivationCell"
  }
  
  class func height() -> CGFloat {
    return 90
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
