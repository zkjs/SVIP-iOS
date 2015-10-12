//
//  InvoiceAddCell.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/27.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class InvoiceAddCell: UITableViewCell {
  
  @IBOutlet weak var invoiceTextField: UITextField!
  @IBOutlet weak var promptTextField: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    layer.borderWidth = 1
    layer.cornerRadius = 5
    
    invoiceTextField.placeholder = NSLocalizedString("INVOICE_NAME", comment: "")
    promptTextField.placeholder = NSLocalizedString("INVOICE_PROMPT", comment: "")
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    self.frame = CGRectMake(self.frame.origin.x + 5, self.frame.origin.y + 5, self.frame.width - 10, self.frame.height - 10)
  }
}
