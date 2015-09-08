//
//  NewItemCell.swift
//  SVIP
//
//  Created by Hanton on 8/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class NewItemCell: UITableViewCell {

  @IBOutlet weak var receiptNO: UILabel!
  @IBOutlet weak var title: UILabel!
  
  class func reuseIdentifier() -> String {
    return "NewItemCellReuseId"
  }
  
  class func nibName() -> String {
    return "NewItemCell"
  }
  
  class func height() -> CGFloat {
    return 60.0
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    backgroundColor = UIColor.clearColor()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
