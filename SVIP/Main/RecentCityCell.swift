//
//  RecentCityCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/18.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class RecentCityCell: UITableViewCell {

  @IBOutlet weak var JCTagView: JCTagListView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "RecentCityCell"
  }
  
  class func nibName() -> String {
    return "RecentCityCell"
  }
  
  class func height() -> CGFloat {
    return 200
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
