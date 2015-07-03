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
  
  @IBOutlet weak var logo: MIBadgeButton!
  
  class func reuseIdentifier()->String {
    return kCellReuseId
  }
  
  class func nibName()->String {
    return kHotelMessageCell
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    logo.badgeEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 0.0, 10.0)
    logo.badgeBackgroundColor = UIColor.redColor()
    logo.badgeString = "1"
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
