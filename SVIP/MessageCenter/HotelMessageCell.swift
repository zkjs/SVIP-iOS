//
//  HotelMessageCell.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kCellReuseId = "HotelMessageCellReuseId"
private let kHotelMessageCell = "HotelMessageCell"

class HotelMessageCell: UITableViewCell {
  
  class func reuseIdentifier()->String {
    return kCellReuseId
  }
  
  class func nibName()->String {
    return kHotelMessageCell
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
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
