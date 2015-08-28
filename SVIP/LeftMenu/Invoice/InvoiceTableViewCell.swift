//
//  InvoiceTableViewCell.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/17.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
protocol InvoiceTableViewCellDelegate: NSObjectProtocol {
  func deleteWithIndex(row: Int)
  func modifyWithIndex(row: Int)
}
class InvoiceTableViewCell: UITableViewCell {
  weak var delegate: InvoiceTableViewCellDelegate?
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var invoiceTextField: UITextField!
  @IBOutlet weak var modifyButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    layer.borderWidth = 1
    layer.cornerRadius = 5
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    self.frame = CGRectMake(self.frame.origin.x + 5, self.frame.origin.y + 5, self.frame.width - 10, self.frame.height - 10)
  }

  @IBAction func modifyInvoice(sender: UIButton) {
    self.delegate?.modifyWithIndex(self.tag)
  }

  @IBAction func deleteInvoice(sender: UIButton) {
    self.delegate?.deleteWithIndex(self.tag)
  }
}
