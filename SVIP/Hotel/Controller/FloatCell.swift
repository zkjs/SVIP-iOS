//
//  FloatCell.swift
//  SVIP
//
//  Created by Hanton on 1/9/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class FloatCell: UITableViewCell {
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  class func reuseIdentifier() -> String {
    return "FloatCell"
  }
  
  class func nibName() -> String {
    return "FloatCell"
  }
  
  class func height() -> CGFloat {
    return 100
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setData(privilege: PrivilegeModel) {
    titleLabel.text = privilege.privilegeName
    contentLabel.text = privilege.privilegeDesc
  }
  
}
