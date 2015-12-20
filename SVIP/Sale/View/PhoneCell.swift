//
//  PhoneCell.swift
//  SVIP
//
//  Created by Hanton on 12/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class PhoneCell: UITableViewCell {
  
  @IBOutlet weak var phoneLabel: UILabel!

  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    phoneLabel.text = ""
  }
  
  class func reuseIdentifier() -> String {
    return "PhoneCell"
  }
  
  class func nibName() -> String {
    return "PhoneCell"
  }
  
  class func height() -> CGFloat {
    return 45
  }
  
  func setData(sales: SalesModel) {
    phoneLabel.text = sales.phone.stringValue
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
