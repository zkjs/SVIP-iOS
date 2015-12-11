//
//  HotCityCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/18.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotCityCell: UITableViewCell {
  
  @IBOutlet weak var JCTagView: JCTagListView!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  class func reuseIdentifier() -> String {
    return "HotCityCell"
  }
  
  class func nibName() -> String {
    return "HotCityCell"
  }
  
  class func height() -> CGFloat {
    return 50
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
