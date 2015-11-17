//
//  MessageCell.swift
//  SVIP
//
//  Created by Hanton on 11/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kCellReuseId = "ConversationCellReuseId"
private let kConversationCell = "ConversationCell"

class ConversationCell: UITableViewCell {
  
  @IBOutlet weak var logo: MIBadgeButton!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var message: UILabel!
  @IBOutlet weak var date: UILabel!
  
  class func reuseIdentifier()->String {
    return kCellReuseId
  }
  
  class func nibName()->String {
    return kConversationCell
  }
  
  class func height() -> CGFloat {
    return 82.0
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    logo.badgeEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 0.0, 10.0)
    logo.badgeBackgroundColor = UIColor.redColor()
    logo.badgeString = nil
  }
  
  func setData(group: EMGroup) {
    title.text = group.groupSubject
    message.text = group.groupDescription
  }
  
}
