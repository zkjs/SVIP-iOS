//
//  TableViewCellNoData.swift
//  SVIP
//
//  Created by Qin Yejun on 3/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class TableViewCellNoData: UITableViewCell {
  @IBOutlet weak var tipsLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  class func reuseIdentifier() -> String {
    return "TableViewCellNoData"
  }
  
  class func nibName() -> String {
    return "TableViewCellNoData"
  }
  
  class func height() -> CGFloat {
    return 100
  }
  
  func setTips(tips:String) {
    tipsLabel.text = tips
  }
}
