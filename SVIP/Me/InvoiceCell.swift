//
//  InvoiceCell.swift
//  SVIP
//
//  Created by Hanton on 12/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class InvoiceCell: SWTableViewCell {
  
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var promptLabel: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  class func reuseIdentifier() -> String {
    return "InvoiceCell"
  }
  
  class func nibName() -> String {
    return "InvoiceCell"
  }
  
  class func height() -> CGFloat {
    return 123.0
  }
  
  func setData(invoice: InvoiceModel) {
    rightUtilityButtons = rightButtons() as [AnyObject]
    if invoice.isDefault {
      headerLabel.text = "默认发票"
    }
    titleLabel.text = "发票抬头:  \(invoice.title)"
  }
  
  func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = []
    rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "删除")
    return rightUtilityButtons
  }
  
}
