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
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var tips: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var date: UILabel!
  
  class func reuseIdentifier()->String {
    return kCellReuseId
  }
  
  class func nibName()->String {
    return kHotelMessageCell
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    name.text = ""
    status.text = ""
    tips.text = ""
    date.text = ""
    logo.badgeEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 0.0, 10.0)
    logo.badgeBackgroundColor = UIColor.redColor()
    logo.badgeString = nil
    
//    layoutMargins = UIEdgeInsetsZero
//    preservesSuperviewLayoutMargins = false
  }
  
}
