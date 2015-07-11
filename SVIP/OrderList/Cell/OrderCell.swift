//
//  OrderCell.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kCellReuseId = "OrderCellReuseId"
private let kOrderCell = "OrderCell"

class OrderCell: SWTableViewCell {
  
  @IBOutlet weak var bookingImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!

  class func reuseIdentifier() -> String {
    return kCellReuseId
  }
  
  class func nibName() -> String {
    return kOrderCell
  }
  
  class func height() -> CGFloat {
    return 116.0
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.selectionStyle = .None
  }
  
  //  func setCity(city: YALCity) {
  //    self.nameLable?.text = city.name
  //    self.pictureImageView?.alpha = 0.0
  //    self.pictureImageView?.image = city.image
  //
  //    UIView.animateWithDuration(0.3, animations: { () -> Void in
  //      self.pictureImageView?.alpha = 1.0
  //      return
  //    })
  //  }
    
}
